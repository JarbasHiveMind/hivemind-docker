#!/bin/bash

# satellite.list file
satellite_list=~/.config/mycroft/satellite.list
satellite_list_state=~/.local/state/mycroft/satellite.state

# Identity files. HIVEMIND-CRYPTO-1 §2: one identity per application, so
# hivemind-voice-sat 2.2.6a1 and later keep their own under hivemind/voice-sat/
# and read the shared file, with a warning, only when that one is missing.
# Older releases read the shared file only. Which one this image carries
# depends on the channel's constraints, so ask the installed package instead
# of assuming: does its launcher name itself?
app_identity_file=~/.config/hivemind/voice-sat/_identity.json
shared_identity_file=~/.config/hivemind/_identity.json
if python3 -c 'import inspect, hivemind_voice_satellite.__main__ as m; raise SystemExit(0 if "app_name=" in inspect.getsource(m) else 1)' 2>/dev/null; then
    names_itself=1
    set_identity="hivemind-client --app voice-sat set-identity"
else
    names_itself=0
    set_identity="hivemind-client set-identity"
fi

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
# from the hivemind_cli container. A satellite that names itself takes its
# own file first, then the shared one with a notice on how to move. An older
# satellite reads the shared file only: its own file must not start it, or it
# would start with no credentials and wait for an audio pairing that never
# comes.
if [ "$names_itself" = 1 ] && test -f "$app_identity_file"; then
    exec hivemind-voice-sat
fi

if test -f "$shared_identity_file"; then
    if [ "$names_itself" = 1 ]; then
        echo "Notice: no identity at ${app_identity_file}; the satellite reads the shared"
        echo "${shared_identity_file}. To give it an identity of its own, run once:"
        echo "    docker exec -it hivemind_cli ${set_identity} \\"
        echo "        --key <key> --password <password> --host ws://<hub> --port 5678"
    fi
    exec hivemind-voice-sat
fi

if [ "$names_itself" = 0 ] && test -f "$app_identity_file"; then
    echo "Notice: ${app_identity_file} exists but this satellite release reads only"
    echo "${shared_identity_file}. It starts from the environment credentials instead."
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
    if [ "$names_itself" = 1 ]; then
        echo "Error: no identity at ${app_identity_file} and no credentials in the environment."
    else
        echo "Error: no identity at ${shared_identity_file} and no credentials in the environment."
    fi
    echo "Missing:${missing}"
    echo
    echo "Ask the hub for a client (it prints the key and password):"
    echo "    hivemind-core add-client"
    echo "then either set VOICE_SAT_KEY, VOICE_SAT_PASSWORD and VOICE_SAT_HOST in the"
    echo "compose .env file, or write the satellite's identity into the configuration folder:"
    echo "    docker exec -it hivemind_cli ${set_identity} \\"
    echo "        --key <key> --password <password> --host ws://<hub> --port 5678"
    exit 1
fi

exec hivemind-voice-sat --key "$VOICE_SAT_KEY" --password "$VOICE_SAT_PASSWORD" --host "$VOICE_SAT_HOST" --port "$VOICE_SAT_PORT" --siteid "$HIVEMIND_SITEID"
