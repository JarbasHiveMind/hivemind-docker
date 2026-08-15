#!/bin/bash
# Runs inside the hivemind-core hub container, once, before `hivemind-core
# listen` starts. Mints one HiveMind client per bridge listed in
# HIVEMIND_BRIDGES (space-separated) and whitelists the message types it
# needs, then writes the resulting access-key/password pair to
# /creds/<bridge>.env so the bridge container can source it.
#
# Idempotent: if /creds/<bridge>.env already exists, that bridge is
# skipped, so a `docker compose up` after the first run does not mint new
# clients or touch the existing database.
set -euo pipefail

CREDS_DIR="${CREDS_DIR:-/creds}"
mkdir -p "$CREDS_DIR"

# message types every conversational bridge needs
BASE_MSGS=(recognizer_loop:utterance speak)
# extra message types the media-player hub needs (OCP playback control)
PLAYER_MSGS=(
  ovos.common_play.play
  ovos.common_play.pause
  ovos.common_play.resume
  ovos.common_play.stop
  ovos.common_play.next
  ovos.common_play.previous
  ovos.common_play.search
  ovos.common_play.status
)

add_client() {
  local bridge="$1"
  local out="$CREDS_DIR/${bridge}.env"
  if [ -f "$out" ]; then
    echo "[hub-init] ${bridge}: credentials already exist, skipping"
    return
  fi

  echo "[hub-init] ${bridge}: minting HiveMind client"
  local result
  result="$(hivemind-core add-client --name "hivemind-selfhost-${bridge}" 2>&1)"

  local node_id access_key password
  node_id="$(grep -oP 'Node ID:\s*\K\S+' <<<"$result")"
  access_key="$(grep -oP 'Access Key:\s*\K\S+' <<<"$result")"
  password="$(grep -oP 'Password:\s*\K\S+' <<<"$result")"

  if [ -z "$access_key" ] || [ -z "$password" ] || [ -z "$node_id" ]; then
    echo "[hub-init] ${bridge}: FAILED to parse add-client output:" >&2
    echo "$result" >&2
    exit 1
  fi

  for msg in "${BASE_MSGS[@]}"; do
    hivemind-core allow-msg "$msg" "$node_id" >/dev/null
  done
  if [ "$bridge" = "media-player" ]; then
    for msg in "${PLAYER_MSGS[@]}"; do
      hivemind-core allow-msg "$msg" "$node_id" >/dev/null
    done
  fi

  # written atomically (temp file + rename) so a bridge container polling
  # for this file never reads a half-written one
  local tmp
  tmp="$(mktemp "${CREDS_DIR}/.${bridge}.XXXXXX")"
  {
    echo "HIVEMIND_ACCESS_KEY=${access_key}"
    echo "HIVEMIND_PASSWORD=${password}"
    echo "HIVEMIND_NODE_ID=${node_id}"
  } >"$tmp"
  mv "$tmp" "$out"
  echo "[hub-init] ${bridge}: credentials written to $out"
}

for bridge in ${HIVEMIND_BRIDGES:-}; do
  add_client "$bridge"
done

echo "[hub-init] bootstrap done, handing off to hivemind-core listen"
exec hivemind-core listen
