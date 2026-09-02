# Grounded in the verified ser9 systemd unit (hivemind-bridge-matrix.service).
#
# IMPORTANT / TODO: unlike the other bridges, `HiveMind-matrix run --help`
# takes NO --host/--port/--access-key/--password flags at all — it reads a
# pre-paired identity from $XDG_CONFIG_HOME/hivemind/_identity.json
# (RSA keypair + access_key/password, produced once via a pairing flow).
# The shared bootstrap in this stack only mints plain access-key/password
# credentials (hivemind-core add-client) — it does NOT yet generate this
# identity.json's RSA keypair, so the matrix bridge is NOT auto-paired by
# `hub-init.sh` today. Until that's added, pair manually:
#   docker compose --profile matrix run --rm matrix-bridge \
#     HiveMind-matrix register   # (or equivalent pairing command)
# and the result will persist in the `matrix-bridge-config` volume.
# TODO / real finding: this bridge's own requirements.txt pins
# "hivemind-bus-client<1.0.0", conflicting with the 1.0.13a1 floor used
# elsewhere in this stack. Installed as-is (its own floor) rather than
# forcing a newer client and breaking the build — needs an upstream floor
# bump + relock before this bridge runs against the current client line.
FROM python:3.13-slim@sha256:9d2e5553305c7c7b0097999bb17187c69b921ccd6bc9d40e4bb5ebe652c00285

ENV PIP_NO_CACHE_DIR=1
RUN pip install --no-cache-dir --pre --upgrade "hivemind-matrix-bridge"

ENV XDG_CONFIG_HOME=/config \
    MATRIX_BOTNAME=hivemind-bot \
    MATRIX_ROOM="#hivemind:localhost"

ENTRYPOINT ["sh", "-c", "exec HiveMind-matrix run \
  --botname \"$MATRIX_BOTNAME\" \
  --matrixtoken \"$MATRIX_TOKEN\" \
  --matrixhost \"$MATRIX_HOMESERVER\" \
  --room \"$MATRIX_ROOM\""]
