#!/bin/bash

set -e

function hivemind_set_identity() {
    # This function sets the Hivemind identity using the provided key, password, host and port.

    # :param key: The identity key to set in Hivemind
    # :param password: The identity password to set in Hivemind
    # :param host: The Hivemind server's host (ws:// or wss://)
    # :param port: The Hivemind server's port number
    local key=$1
    local password=$2
    local host=$3
    local port=$4

    # The chatroom builds its client with no identity, so it reads the shared
    # file. hivemind-bus-client 1.3.0a1 and later write that file only with
    # --shared; older releases have no --shared and write it by default.
    local target=()
    if hivemind-client --help 2>/dev/null | grep -q -- '--shared'; then
        target=(--shared)
    fi

    if ! hivemind-client "${target[@]}" set-identity --key "$key" --password "$password" --host "$host" --port "$port"; then
        echo "Error: Failed to set Hivemind identity."
        return 1
    fi

    return 0
}

if ! hivemind_set_identity "$SAT_KEY" "$SAT_PASSWORD" "$SAT_HOST" "$SAT_PORT"; then
    exit 1
fi

exec hivemind-flask-chatroom
