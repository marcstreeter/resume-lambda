FROM nginx:alpine

# Install gettext package for envsubst command
RUN apk add --no-cache gettext

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/nginx.conf

# Copy nginx configuration
COPY interface/nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY interface/index.html /usr/share/nginx/html/index.html
COPY interface/openapi.yaml /usr/share/nginx/html/openapi.yaml

# Copy and set up startup script
COPY interface/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose port 80
EXPOSE 80

# Start using our custom script
CMD ["/usr/local/bin/start.sh"]