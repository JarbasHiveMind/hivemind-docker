ARG TAG=alpha
FROM smartgic/hivemind-base:${TAG}

ARG BUILD_DATE=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="HiveMind OS OCI Chatroom"
LABEL org.opencontainers.image.description="This simple WebUI allows you to securely interact with your OpenVoiceOS instance through HiveMind."
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/"
LABEL org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker"
LABEL org.opencontainers.image.vendor="HiveMind"

ARG ALPHA=false
ARG USER=hivemind

COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN if [ "${ALPHA}" == "true" ]; then \
  pip3 install --no-cache-dir hivemind-flask-chatroom --pre; \
  else \
  pip3 install --no-cache-dir hivemind-flask-chatroom; \
  fi

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR /home/${USER}

EXPOSE 8985
