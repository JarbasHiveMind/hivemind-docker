# Grounded in ser9's hivemind-bridge-mattermost.service:
#   hivemind-mattermost-bridge --mail ... --pswd ... --url ... --tag ...
#   --host ws://127.0.0.1 --port 5678 --key ... --password ... --lang en-us
#
# TODO / real finding: this bridge's own requirements.txt pins
# "hivemind-bus-client<1.0.0", which conflicts with the current
# hivemind-bus-client 1.0.13a1 floor used elsewhere in this stack. We do
# NOT force a newer hivemind-bus-client here — that reintroduces the pip
# ResolutionImpossible this comment is warning about. This needs an
# upstream floor bump + relock in the bridge repo itself before the whole
# stack can run one consistent hivemind-bus-client version. Tracked as a
# TODO, not silently worked around.
FROM python:3.12-slim

ENV PIP_NO_CACHE_DIR=1
RUN pip install --no-cache-dir --pre --upgrade \
    "hivemind-mattermost-bridge"

COPY wait-for-creds.sh /usr/local/bin/wait-for-creds.sh
RUN chmod +x /usr/local/bin/wait-for-creds.sh

ENV HIVEMIND_HOST=ws://hub \
    HIVEMIND_PORT=5678 \
    HIVEMIND_LANG=en-us \
    MATTERMOST_URL=mattermost \
    MATTERMOST_TAG=@hivemind_bridge_bot \
    MMOST_SCHEME=http \
    MMOST_PORT=8065 \
    MMOST_VERIFY=0 \
    CREDS_DIR=/creds

ENTRYPOINT ["/usr/local/bin/wait-for-creds.sh", "mattermost", "--"]
CMD ["sh", "-c", "exec hivemind-mattermost-bridge \
  --mail \"$MATTERMOST_EMAIL\" --pswd \"$MATTERMOST_PASSWORD\" \
  --url \"$MATTERMOST_URL\" --tag \"$MATTERMOST_TAG\" \
  --host \"$HIVEMIND_HOST\" --port \"$HIVEMIND_PORT\" \
  --key \"$HIVEMIND_ACCESS_KEY\" --password \"$HIVEMIND_PASSWORD\" \
  --lang \"$HIVEMIND_LANG\""]
