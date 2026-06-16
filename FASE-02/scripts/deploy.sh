#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FASE02_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$(dirname "$FASE02_DIR")"
COMPOSE_FILE="$FASE02_DIR/docker-compose.yml"

MODE="${1:-compose}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
IMAGE_NAME="${IMAGE_NAME:-desafio-iac}"
APP_IMAGE="${APP_IMAGE:-$IMAGE_NAME:$IMAGE_TAG}"

echo "==> Deploy Desafio-IaC (modo: $MODE)"

build_image() {
  echo "==> Building Docker image..."
  docker build \
    -f "$FASE02_DIR/docker/dockerfile" \
    -t "$APP_IMAGE" \
    "$ROOT_DIR"
}

deploy_compose() {
  export APP_IMAGE
  if [[ "$APP_IMAGE" == */* ]]; then
    echo "==> Using registry image: $APP_IMAGE"
    docker compose -f "$COMPOSE_FILE" pull app
  else
    build_image
  fi
  echo "==> Starting Docker Compose stack..."
  docker compose -f "$COMPOSE_FILE" up -d
  echo "==> App:        http://localhost:8080/"
  echo "==> Prometheus: http://localhost:9090/"
  echo "==> Grafana:    http://localhost:3000/"
}

deploy_registry() {
  if [[ -z "${GHCR_IMAGE:-}" ]]; then
    echo "Defina GHCR_IMAGE (ex: ghcr.io/usuario/desafio-iac:latest)"
    exit 1
  fi
  APP_IMAGE="$GHCR_IMAGE" deploy_compose
}

case "$MODE" in
  compose)
    deploy_compose
    ;;
  registry)
    deploy_registry
    ;;
  build)
    build_image
    ;;
  *)
    echo "Uso: $0 [compose|registry|build]"
    exit 1
    ;;
esac
