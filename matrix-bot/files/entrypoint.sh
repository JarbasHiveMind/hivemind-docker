#!/bin/bash

set -e

function hivemind_set_identity() {
    # This function sets the Hivemind identity using the provided key, password, host and port.

    # :param key: The identity key to set in Hivemind
    # :param password: The identity password to set in Hivemind
    # :param host: The Hivemind server's host (ws:// or http(s)://)
    # :param port: The Hivemind server's port number
    local key=$1
    local password=$2
    local host=$3
    local port=$4

    if ! hivemind-client set-identity --key "$key" --password "$password" --host "$host" --port "$port"; then
        echo "Error: Failed to set Hivemind identity."
        return 1
    fi

    return 0
}

function run_matrix() {
    # This function starts the Matrix bot with the provided name, token, host and room.

    # :param botname: The name of the Matrix bot
    # :param matrixtoken: The access token for the Matrix bot
    # :param matrixhost: The Matrix server's host (ws:// or http(s)://)
    # :param room: The room where the Matrix bot will join
    local botname=$1
    local matrixtoken=$2
    local matrixhost=$3
    local room=$4

    if ! HiveMind-matrix run --botname "$botname" --matrixtoken "$matrixtoken" --matrixhost "$matrixhost" --room "$room"; then
        echo "Error: Failed to start Matrix bot."
        return 1
    fi

    return 0
}

if ! hivemind_set_identity "$VOICE_SAT_KEY" "$VOICE_SAT_PASSWORD" "$VOICE_SAT_HOST" "$VOICE_SAT_PORT"; then
    exit 1
fi

if ! run_matrix "$MATRIX_BOT_NAME" "$MATRIX_TOKEN" "$MATRIX_HOST" "$MATRIX_ROOM"; then
    exit 1
fi
