# Stage 1: Build dependencies with Poetry and export to requirements.txt
FROM python:3.12-bookworm AS builder
# Set environment variables for Poetry
ENV POETRY_VIRTUALENVS_CREATE=false \
    POETRY_NO_INTERACTION=1 \
    PATH="/root/.local/bin:$PATH"
# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.8.3
# Copy the project files (only pyproject.toml and poetry.lock are needed for dependencies)
WORKDIR /app
COPY pyproject.toml poetry.lock /app/
# Export to requirements.txt (including dev dependencies)
RUN poetry export --without-hashes --with dev --format requirements.txt --output requirements.txt
# Install dependencies into a temporary directory for copying later
RUN mkdir -p /app/deps && pip install -r requirements.txt -t /app/deps

# Stage 2: Final runtime image
FROM public.ecr.aws/lambda/python:3.12
ENV _HANDLER=main.lambda_handler \
    PYTHONPATH="/opt/python/lib/python3.12/site-packages:$PYTHONPATH" \
    PYDEVD_DISABLE_FILE_VALIDATION=1
RUN dnf install -y tar  # needed for tilt live_update feature

# Copy dependencies from the builder stage to /var/task
#   NOTE: lambda need this location to locate dependencies, this seems to differ
#         from the actual lambda that just allows for the dependencies to reside
#         next to the main.py file but this way works
COPY --from=builder /app/deps /opt/python/lib/python3.12/site-packages
# Ensure directory present so that copies into it do not fail
RUN mkdir -p /var/task/src
# Copy application code to /var/task without overwriting existing files
COPY src/* /var/task/src
# Expose port 8080 for HTTP requests to the Lambda function
EXPOSE 8080
# Expose port 5678 for debugpy
EXPOSE 5678
#
WORKDIR /var/task/src
# Use the Lambda Runtime Interface Emulator to start the container in local mode
CMD ["main.lambda_handler"]