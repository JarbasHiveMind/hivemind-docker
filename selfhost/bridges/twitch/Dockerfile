# NOT published to PyPI (verified: `pip index versions HiveMind-twitch-bridge`
# resolves nothing) — install from the repo checkout, same as the
# hivemind-telegram-bridge repo's own Dockerfile does. This file is meant
# to be committed to JarbasHiveMind/HiveMind-twitch-bridge itself (build
# context = repo root); the selfhost stack builds this bridge straight
# from that repo's git URL rather than duplicating a copy here.
FROM python:3.12-slim@sha256:09f7da3bc104798d0afb40bc08d23ab2da20a76130cec1f2ef170848f5d85217

WORKDIR /app
COPY . /app

# TODO / real finding: HiveMind-twitch-bridge's own requirements.txt pins
# "hivemind-bus-client>=0.9.2a1,<1.0.0" — an upper bound that conflicts
# with the current 1.0.13a1 floor. We install the package as-is (its own
# floor) rather than forcing a newer client and breaking the build; this
# needs an upstream floor bump + relock before the bridge can run against
# the current hivemind-bus-client line.
RUN pip install --no-cache-dir --pre .

ENV HIVEMIND_HOST=ws://hub \
    HIVEMIND_PORT=5678 \
    HIVEMIND_LANG=en-us \
    TWITCH_NICKNAME=hivemind_bot

ENTRYPOINT ["sh", "-c", "exec hivemind-twitch-bridge \
  --channel \"$TWITCH_CHANNEL\" --oauth \"$TWITCH_OAUTH\" \
  --nickname \"$TWITCH_NICKNAME\" --lang \"$HIVEMIND_LANG\" \
  --access-key \"$HIVEMIND_ACCESS_KEY\" --password \"$HIVEMIND_PASSWORD\" \
  --host \"$HIVEMIND_HOST\" --port \"$HIVEMIND_PORT\""]
