#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="taskmaster"
CONTAINER_NAME="taskmaster"
HOST_DATA_DIR="/taskmaster"
DOMAIN="taskmaster.vixal.net"

echo "[taskmaster] Ensuring host data directory exists: ${HOST_DATA_DIR}"
sudo mkdir -p "${HOST_DATA_DIR}"

echo "[taskmaster] Ensuring YAML data files exist"
if [ ! -f "${HOST_DATA_DIR}/urgent.yaml" ]; then
  sudo tee "${HOST_DATA_DIR}/urgent.yaml" >/dev/null <<'EOF'
- Drink coffee
- Check email
- Work on Frame Analytics
EOF
fi

if [ ! -f "${HOST_DATA_DIR}/tasks.yaml" ]; then
  sudo tee "${HOST_DATA_DIR}/tasks.yaml" >/dev/null <<'EOF'
- Buy more scent-free clothes
- Review VOC detector options
- Organize notes for Nick Cole
EOF
fi

if [ ! -f "${HOST_DATA_DIR}/completed.yaml" ]; then
  sudo tee "${HOST_DATA_DIR}/completed.yaml" >/dev/null <<'EOF'
[]
EOF
fi

if [ ! -f "${HOST_DATA_DIR}/.htpasswd" ]; then
  echo "[taskmaster] WARNING: ${HOST_DATA_DIR}/.htpasswd does not exist."
  echo "[taskmaster] Create it before logging in, for example:"
  echo "[taskmaster]   sudo htpasswd -c -B ${HOST_DATA_DIR}/.htpasswd james"
fi

echo "[taskmaster] Building Docker image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" .

echo "[taskmaster] Stopping old container if it exists"
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "[taskmaster] Pruning stopped containers and dangling images"
docker container prune -f
docker image prune -f

echo "[taskmaster] Starting new container"
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p 443:443 \
  -v "${HOST_DATA_DIR}:/taskmaster" \
  -v "/etc/letsencrypt:/etc/letsencrypt:ro" \
  "${IMAGE_NAME}"

echo "[taskmaster] Running at: https://${DOMAIN}"
echo "[taskmaster] Auth file: ${HOST_DATA_DIR}/.htpasswd"
