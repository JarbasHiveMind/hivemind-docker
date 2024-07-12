#!/bin/bash

# satellite.list file
satellite_list=~/.config/mycroft/satellite.list

# _identity.json file
identity_file=~/.config/hivemind/_identity.json

# Install STT/TTS plugins, microphone plugins or others Python libraries via pip command when a setup.py exists
if test -f "$satellite_list"; then
    pip3 install -r "$satellite_list"
fi

# Clear Python cache
rm -rf ~/.cache/pip

# Auto-detect which sound server is running (PipeWire or PulseAudio)
if pactl info &> /dev/null; then
    echo -e 'pcm.!default pulse\nctl.!default pulse' > ~/.asoundrc
elif pw-link --links &> /dev/null; then
    echo -e 'pcm.!default pipewire\nctl.!default pipewire' > ~/.asoundrc
fi

# Check if _identify file exists and leverage it
if test -f "$identity_file"; then
    hivemind-voice-sat
else
    hivemind-voice-sat --key "$VOICE_SAT_KEY" --password "$VOICE_SAT_PASSWORD" --host "$VOICE_SAT_HOST" --port "$VOICE_SAT_PORT" --siteid "$HIVEMIND_SITEID"
fi
