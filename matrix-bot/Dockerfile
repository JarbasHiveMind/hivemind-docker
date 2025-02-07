ARG TAG=alpha
FROM smartgic/hivemind-base:${TAG}

ARG BUILD_DATE=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="HiveMind OS OCI Matrix bot"
LABEL org.opencontainers.image.description="Connecting in a Matrix chatroom to HiveMind"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/"
LABEL org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker"
LABEL org.opencontainers.image.vendor="HiveMind"

ARG ALPHA=false
ARG USER=hivemind

COPY --chown=${USER}:${USER} files/requirements.txt /tmp/requirements.txt
COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN if [ "${ALPHA}" == "true" ]; then \
  pip3 install --no-cache-dir -r /tmp/requirements.txt --pre; \
  else \
  pip3 install --no-cache-dir -r /tmp/requirements.txt; \
  fi \
  && rm -rf /tmp/requirements.txt

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"
