#!/usr/bin/env bash
# Smoke validation for the hivemind-docker stack.
#
# Runs the cheap, dependency-light checks first (compose config parse + bake
# graph render), then optionally a real local image build when --build is given.
# Designed to run both in CI and on a developer machine.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DO_BUILD="false"
BUILD_TARGETS="${BUILD_TARGETS:-stack}"

usage() {
  cat <<EOF
Usage: $0 [options]

Validates the compose files and the Buildx Bake graph. Optionally builds images.

Options:
  --build            Also run a local image build (docker buildx bake --load).
  --targets TARGETS  Bake targets to build with --build (default: ${BUILD_TARGETS}).
  -h, --help         Show this help.

Environment:
  BUILD_TARGETS      Same as --targets.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build) DO_BUILD="true"; shift ;;
    --targets) BUILD_TARGETS="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

have() { command -v "$1" >/dev/null 2>&1; }

fail=0

echo "==> Checking required tooling"
if ! have docker; then
  echo "ERROR: docker not found; cannot run smoke checks." >&2
  exit 1
fi
docker --version

# docker compose v2 (plugin) or legacy docker-compose
COMPOSE=()
if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose)
elif have docker-compose; then
  COMPOSE=(docker-compose)
else
  echo "ERROR: neither 'docker compose' nor 'docker-compose' is available." >&2
  exit 1
fi
echo "Using compose: ${COMPOSE[*]}"

# Provide values for the variables referenced by the compose files so that
# `config` can interpolate without warnings. These are validation-only values.
ENV_FILE="$(mktemp)"
trap 'rm -f "$ENV_FILE"' EXIT
cp compose/.env-example "$ENV_FILE"

echo
echo "==> Validating compose files (config parse + interpolation)"
shopt -s nullglob
compose_files=(compose/docker-compose*.yml)
if [[ ${#compose_files[@]} -eq 0 ]]; then
  echo "ERROR: no compose files found under compose/." >&2
  exit 1
fi
for cf in "${compose_files[@]}"; do
  echo "--- $cf"
  if "${COMPOSE[@]}" --env-file "$ENV_FILE" -f "$cf" config -q; then
    echo "    OK"
  else
    echo "    FAILED" >&2
    fail=1
  fi
done

echo
echo "==> Rendering Buildx Bake graph (no build)"
if docker buildx version >/dev/null 2>&1; then
  if docker buildx bake --print >/dev/null; then
    echo "    OK"
  else
    echo "    FAILED" >&2
    fail=1
  fi
else
  echo "    SKIP: docker buildx not available"
fi

if [[ "$DO_BUILD" == "true" ]]; then
  echo
  echo "==> Building images locally (targets: ${BUILD_TARGETS})"
  # scripts/bake.sh --load builds linux/amd64 into the local docker engine.
  if ./scripts/bake.sh --load --no-push -T "${BUILD_TARGETS}"; then
    echo "    OK"
  else
    echo "    FAILED" >&2
    fail=1
  fi
fi

echo
if [[ "$fail" -eq 0 ]]; then
  echo "SMOKE: PASS"
else
  echo "SMOKE: FAIL" >&2
fi
exit "$fail"
