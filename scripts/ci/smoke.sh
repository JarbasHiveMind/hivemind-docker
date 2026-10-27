#!/usr/bin/env bash
# Runtime smoke test, executed inside a freshly built image (docker run … --entrypoint /bin/bash -s < smoke.sh).
# Proves the image can actually start: interpreter present, installed packages consistent, entrypoint
# script parses, and the binary it execs exists.
set -euo pipefail

if ! command -v python > /dev/null; then
  echo "no python interpreter: not a Python image, nothing to check"
  exit 0
fi
python -V
pip check

# Metadata can be consistent while imports fail (bitstring 5 removed BitStream).
python - <<'PYTHON'
from importlib.util import find_spec

if find_spec("hivemind_bus_client") is not None:
    from hivemind_bus_client import serialization
    print("HiveMind serialization: import ok")
PYTHON

if [ -f /usr/local/bin/entrypoint.sh ]; then
  bash -n /usr/local/bin/entrypoint.sh
  echo "entrypoint.sh: syntax ok"
  bin=$(grep -oE '^\s*exec [A-Za-z0-9_./-]+' /usr/local/bin/entrypoint.sh | tail -1 | awk '{print $2}' || true)
  if [ -n "${bin:-}" ] && [ "$bin" != '"$@"' ]; then command -v "$bin" > /dev/null; echo "entrypoint.sh execs $bin: found"; fi
fi

if [ -n "${SMOKE_BIN:-}" ]; then
  command -v "$SMOKE_BIN" > /dev/null
  echo "entrypoint binary ${SMOKE_BIN}: found"
fi
echo "smoke ok"
