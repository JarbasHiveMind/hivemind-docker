#!/bin/bash

# Install plugins via pip command when a setup.py exists
mkdir -p ~/.config/hivemind ~/.local/state/hivemind
hivemind_list=~/.config/hivemind/hivemind.list
hivemind_list_state=~/.local/state/hivemind/hivemind.state
if test -f "$hivemind_list"; then
    if ! diff -q -B <(grep -vE '^\s*(#|$)' "$hivemind_list") <(grep -vE '^\s*(#|$)' "$hivemind_list_state" 2>/dev/null) &>/dev/null; then
        if pip3 install --no-cache-dir -r "$hivemind_list"; then
            cp "$hivemind_list" "$hivemind_list_state"
        else
            echo "Error: Failed to install packages from $hivemind_list"
            exit 1
        fi
    fi
fi

# Clear Python cache
rm -rf ~/.cache/pip

# Run hivemind-core
if ! hivemind-core listen; then
    echo "Error: Failed to start hivemind-core"
    exit 1
fi
