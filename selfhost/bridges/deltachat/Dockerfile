# Grounded in ser9's ~/hivemind-bridges/deltachat/run.sh:
#   hm-deltachat-bridge --email ... --email-password ... --key ... \
#     --password ... --host ws://127.0.0.1 --port 5678
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
    "HiveMind-deltachat-bridge"

COPY wait-for-creds.sh /usr/local/bin/wait-for-creds.sh
RUN chmod +x /usr/local/bin/wait-for-creds.sh

ENV XDG_CONFIG_HOME=/config \
    HIVEMIND_HOST=ws://hub \
    HIVEMIND_PORT=5678 \
    CREDS_DIR=/creds

ENTRYPOINT ["/usr/local/bin/wait-for-creds.sh", "deltachat", "--"]
CMD ["sh", "-c", "exec hm-deltachat-bridge \
  --email \"$DELTACHAT_EMAIL\" --email-password \"$DELTACHAT_EMAIL_PASSWORD\" \
  --key \"$HIVEMIND_ACCESS_KEY\" --password \"$HIVEMIND_PASSWORD\" \
  --host \"$HIVEMIND_HOST\" --port \"$HIVEMIND_PORT\""]
