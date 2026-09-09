#!/bin/bash

# satellite.list file
satellite_list=~/.config/mycroft/satellite.list
satellite_list_state=~/.local/state/mycroft/satellite.state

# _identity.json file
identity_file=~/.config/hivemind/_identity.json

# Install STT/TTS plugins, microphone plugins or others Python libraries via pip command when a setup.py exists
if test -f "$satellite_list"; then
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

# An identity written by "hivemind-client set-identity" wins; it lives in the
# mounted configuration folder, so it survives restarts and can be provisioned
# from the hivemind_cli container.
if test -f "$identity_file"; then
    exec hivemind-voice-sat
fi

# Otherwise the credentials must come from the environment. Do not start without
# them: hivemind-voice-sat treats an empty password as "pair over audio" and calls
# hivemind-ggwave, which needs a ggwave-rx binary this image does not ship. That
# fails with a traceback about ggwave-rx that says nothing about the real problem,
# and the container then exits too quickly to exec into.
missing=""
for credential in VOICE_SAT_KEY VOICE_SAT_PASSWORD VOICE_SAT_HOST; do
    if [ -z "${!credential}" ]; then
        missing="${missing} ${credential}"
    fi
done

if [ -n "$missing" ]; then
    echo "Error: no identity at ${identity_file} and no credentials in the environment."
    echo "Missing:${missing}"
    echo
    echo "Ask the hub for a client (it prints the key and password):"
    echo "    hivemind-core add-client"
    echo "then either set VOICE_SAT_KEY, VOICE_SAT_PASSWORD and VOICE_SAT_HOST in the"
    echo "compose .env file, or write an identity into the shared configuration folder:"
    echo "    docker exec -it hivemind_cli hivemind-client set-identity \\"
    echo "        --key <key> --password <password> --host ws://<hub> --port 5678"
    exit 1
fi

exec hivemind-voice-sat --key "$VOICE_SAT_KEY" --password "$VOICE_SAT_PASSWORD" --host "$VOICE_SAT_HOST" --port "$VOICE_SAT_PORT" --siteid "$HIVEMIND_SITEID"
