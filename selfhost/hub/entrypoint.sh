#!/bin/bash
# Starts the OVOS agent stack (messagebus, core, audio) in the background,
# waits for the messagebus to accept connections, then runs the HiveMind
# bootstrap (mints+whitelists one client per enabled bridge) and finally
# execs `hivemind-core listen` in the foreground so it becomes PID 1's
# child and container logs/signals behave normally.
set -e

mkdir -p ~/.config/mycroft ~/.config/hivemind-core
[ -f ~/.config/mycroft/mycroft.conf ] || cp ~/seed/mycroft.conf ~/.config/mycroft/mycroft.conf
[ -f ~/.config/hivemind-core/server.json ] || cp ~/seed/server.json ~/.config/hivemind-core/server.json

echo "[hub] starting ovos-messagebus"
ovos-messagebus &

echo "[hub] waiting for messagebus on 127.0.0.1:8181"
for _ in $(seq 1 60); do
  (echo > /dev/tcp/127.0.0.1/8181) 2>/dev/null && break
  sleep 1
done

echo "[hub] starting ovos-core"
ovos-core &

echo "[hub] starting ovos-audio"
ovos-audio &

exec /home/hivemind/bootstrap/hub-init.sh
