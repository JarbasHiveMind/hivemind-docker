#!/bin/bash

# Install plugins via pip command when a setup.py exists
hivemind_list=~/.config/mycroft/hivemind.list
hivemind_list_state=~/.local/state/mycroft/hivemind.state
if test -f "$hivemind_list"; then
    if ! diff -q -B <(grep -vE '^\s*(#|$)' "$hivemind_list") <(grep -vE '^\s*(#|$)' "$hivemind_list_state" 2>/dev/null) &>/dev/null; then
        pip3 install --no-cache-dir -r "$hivemind_list"
        cp "$hivemind_list" "$hivemind_list_state"
    fi
fi

# Clear Python cache
rm -rf ~/.cache/pip

# Run hivemind-core
hivemind-core listen
