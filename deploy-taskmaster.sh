 #!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="taskmaster"
CONTAINER_NAME="taskmaster"
HOST_DATA_DIR="/taskmaster"
DOMAIN="taskmaster.vixal.net"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[taskmaster] Ensuring host data directory exists: ${HOST_DATA_DIR}"
sudo mkdir -p "${HOST_DATA_DIR}"

echo "[taskmaster] Installing supplied YAML files if missing"
for f in tasks.yaml completed.yaml urgent.yaml; do
  if [ ! -f "${HOST_DATA_DIR}/${f}" ]; then
    sudo cp "${SCRIPT_DIR}/seed-taskmaster/${f}" "${HOST_DATA_DIR}/${f}"
    echo "[taskmaster] Installed ${HOST_DATA_DIR}/${f}"
  else
    echo "[taskmaster] Keeping existing ${HOST_DATA_DIR}/${f}"
  fi
done

if [ ! -f "${HOST_DATA_DIR}/.htpasswd" ]; then
  echo "[taskmaster] WARNING: ${HOST_DATA_DIR}/.htpasswd does not exist."
  echo "[taskmaster] Create it before logging in, for example:"
  echo "[taskmaster]   sudo htpasswd -c -B ${HOST_DATA_DIR}/.htpasswd james"
fi

 htpasswd -n -B -b nc jamesisgay >> "${HOST_DATA_DIR}"/.htpasswd
 htpasswd -n -B -b james goatse69 >> "${HOST_DATA_DIR}"/.htpasswd

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
