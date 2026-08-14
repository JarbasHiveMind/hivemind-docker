#!/bin/bash
# Sourced/run by every bridge container's entrypoint. Waits for the hub's
# hub-init.sh to publish this bridge's credentials into the shared
# `hivemind-creds` volume, then exports them into the environment before
# handing off to the bridge's real command.
#
# Usage: wait-for-creds.sh <bridge-name> -- <command> [args...]
set -euo pipefail

BRIDGE_NAME="$1"
shift
if [ "$1" != "--" ]; then
  echo "usage: wait-for-creds.sh <bridge-name> -- <command> [args...]" >&2
  exit 1
fi
shift

CREDS_FILE="${CREDS_DIR:-/creds}/${BRIDGE_NAME}.env"
TIMEOUT="${CREDS_WAIT_TIMEOUT:-120}"

elapsed=0
until [ -f "$CREDS_FILE" ]; do
  if [ "$elapsed" -ge "$TIMEOUT" ]; then
    echo "[${BRIDGE_NAME}] timed out after ${TIMEOUT}s waiting for $CREDS_FILE" \
      "(is the 'hub' service up and healthy?)" >&2
    exit 1
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done

# shellcheck disable=SC1090
set -a
source "$CREDS_FILE"
set +a

exec "$@"
