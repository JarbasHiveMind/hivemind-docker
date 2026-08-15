#!/bin/bash
set -e

mkdir -p ~/.config/hivemind-core ~/.config/mycroft

if [ ! -f ~/.config/hivemind-core/server.json ]; then
    cp ~/seed/server.json ~/.config/hivemind-core/server.json
fi
if [ ! -f ~/.config/mycroft/mycroft.conf ]; then
    cp ~/seed/mycroft.conf ~/.config/mycroft/mycroft.conf
fi

exec hivemind-core listen
