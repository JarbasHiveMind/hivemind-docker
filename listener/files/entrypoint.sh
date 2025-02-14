#!/bin/bash

# Install plugins via pip command when a setup.py exists
listener_list=~/.config/hivemind/listener.list
listener_list_state=~/.local/state/hivemind/listener.state

if test -f "$listener_list"; then
    if ! diff -q -B <(grep -vE '^\s*(#|$)' "$listener_list") <(grep -vE '^\s*(#|$)' "$listener_list_state" 2>/dev/null) &>/dev/null; then
        if pip3 install --no-cache-dir -r "$listener_list"; then
            cp "$listener_list" "$listener_list_state"
        else
            echo "Error: Failed to install packages from $listener_list"
            exit 1
        fi
    fi
fi

# Run hivemind-core
if ! hivemind-core listen; then
    echo "Error: Failed to start hivemind-core"
    exit 1
fi
