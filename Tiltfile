# Tiltfile for resume-lambda

# checks
allow_k8s_contexts('docker-desktop')

# extensions
load('ext://dotenv', 'dotenv')

# environment variables
DOTENV = dotenv() or {}
API_GATEWAY_URL = str(local(
  'gh variable get API_GATEWAY_URL 2>/dev/null || echo "https://your-api-gateway.amazonaws.com/prod"',
  quiet=True,
)).strip()

# Define the Docker image for the Lambda service
docker_build(
  'resume-lambda-lambda',
  '.',
  dockerfile='Dockerfile',
  # entrypoint=["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "-m", "main"],
  live_update=[
    sync('./src', '/var/task/src'),
  ]
)

# Define the interface service using nginx image
docker_build(
  'resume-lambda-interface',
  '.',
  dockerfile='interface/Dockerfile',
  live_update=[
    sync('interface/index.html', '/usr/share/nginx/html/index.html'),
    sync('interface/openapi.yaml', '/usr/share/nginx/html/openapi.yaml'),
    sync('interface/nginx.conf', '/etc/nginx/nginx.conf'),
  ]
)

# Use Helm to deploy the Lambda service
k8s_yaml(
  helm(
      'manifests',
      namespace='default',
      values=[
          'manifests/values.yaml'
      ],
      set=[
          'project_name=resume-lambda',
          'environment=development',
          'apiGatewayUrl=' + API_GATEWAY_URL,
      ]
  )
)
# Forward the container port 8080 to the host port 18075
k8s_resource(
    workload='resume-lambda-lambda',
    port_forwards=[
        '18075:8080',  # http  port
        # ":5678" # debug port
    ],
)
# Forward the container port 80 to the host port 18070
k8s_resource(
  workload='resume-lambda-interface',
  port_forwards=[
    '18070:80', # http port
  ],
  resource_deps=['resume-lambda-lambda']
)