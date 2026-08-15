# Based on the VERIFIED-WORKING ser9 Dockerfile at
# ~/hivemind-bridges/baresip/Dockerfile (full SIP voice round trip tested
# there). NOT published to PyPI (verified: `pip index versions
# HiveMind-baresip-bridge` resolves nothing) — installed from this repo
# checkout, same as ser9's setup does from a local source tarball.
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    baresip baresip-core ffmpeg \
    ca-certificates curl gcc python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"
RUN uv python install 3.12

WORKDIR /app
COPY . /app/bridge-src
RUN uv venv --python 3.12 .venv
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"

# TODO / real finding: this repo's own pyproject pins
# "hivemind-bus-client>=0.9.2a1" with no upper bound, which is fine on its
# own, but the wider selfhost stack floors hivemind-bus-client at 1.0.13a1
# — pull it in explicitly here (unlike mattermost/hackchat/twitch, this one
# has no conflicting UPPER bound so the newer client resolves cleanly).
RUN uv pip install --python .venv/bin/python --prerelease=allow /app/bridge-src
RUN uv pip install --python .venv/bin/python -U --prerelease=allow "hivemind-bus-client>=1.0.13a1"
RUN uv pip install --python .venv/bin/python --prerelease=allow \
    ovos-stt-plugin-server ovos-vad-plugin-silero

ENV XDG_CONFIG_HOME=/app/config \
    HIVEMIND_HOST=ws://127.0.0.1 \
    HIVEMIND_PORT=5678 \
    SIP_USER=assistant \
    SIP_PASSWORD=assistantpass \
    SIP_GATEWAY=127.0.0.1

# sip_config.json is generated from env vars at container start so
# credentials never live baked into the image or the repo.
ENTRYPOINT ["sh", "-c", "printf '{\"sip_user\":\"%s\",\"sip_password\":\"%s\",\"sip_gateway\":\"%s\",\"sip_transport\":\"udp\",\"auto_answer\":true,\"allowlist\":[]}' \"$SIP_USER\" \"$SIP_PASSWORD\" \"$SIP_GATEWAY\" > /app/sip_config.json && exec hivemind-baresip-bridge \
  --host \"$HIVEMIND_HOST\" --port \"$HIVEMIND_PORT\" \
  --key \"$HIVEMIND_ACCESS_KEY\" --password \"$HIVEMIND_PASSWORD\" \
  --sip-config /app/sip_config.json"]
