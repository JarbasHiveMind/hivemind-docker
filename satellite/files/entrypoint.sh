#!/bin/bash

# satellite.list file
satellite_list=~/.config/mycroft/satellite.list
satellite_list_state=~/.local/state/mycroft/satellite.state

# _identity.json file
identity_file=~/.config/hivemind/_identity.json

# Install STT/TTS plugins, microphone plugins or others Python libraries via pip command when a setup.py exists
if [ -n "$satellite_list" ]; then
    if ! diff -q -B <(grep -vE '^\s*(#|$)' "$satellite_list") <(grep -vE '^\s*(#|$)' "$satellite_list_state" 2>/dev/null) &>/dev/null; then
        pip3 install --no-cache-dir -r "$satellite_list"
        cp "$satellite_list" "$satellite_list_state"
    fi
fi

# Clear Python cache
rm -rf ~/.cache/pip

# Auto-detect which sound server is running (PipeWire or PulseAudio)
asoundrc_file=~/.asoundrc
if test -f ~/.config/mycroft/asoundrc; then
    cp -rfp ~/.config/mycroft/asoundrc "$asoundrc_file"
else
    if pw-link --links &>/dev/null; then
        echo -e 'pcm.!default pipewire\nctl.!default pipewire' >"$asoundrc_file"
    elif pactl info &>/dev/null; then
        echo -e 'pcm.!default pulse\nctl.!default pulse' >"$asoundrc_file"
    fi
fi

# Check if _identify file exists and leverage it
if test -f "$identity_file"; then
    exec hivemind-voice-sat
else
    exec hivemind-voice-sat --key "$VOICE_SAT_KEY" --password "$VOICE_SAT_PASSWORD" --host "$VOICE_SAT_HOST" --port "$VOICE_SAT_PORT" --siteid "$HIVEMIND_SITEID"
fi
