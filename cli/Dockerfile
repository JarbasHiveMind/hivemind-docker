ARG TAG=alpha
FROM smartgic/hivemind-base:${TAG}

ARG BUILD_DATE=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="HiveMind OS OCI CLI"
LABEL org.opencontainers.image.description="Command line to interact with HiveMind"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/"
LABEL org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker"
LABEL org.opencontainers.image.vendor="HiveMind"

ARG ALPHA=false
ARG USER=hivemind

COPY --chown=${USER}:${USER} files/requirements.txt /tmp/requirements.txt

RUN if [ "${ALPHA}" == "true" ]; then \
  pip3 install -r /tmp/requirements.txt --pre; \
  else \
  pip3 install -r /tmp/requirements.txt; \
  fi \
  && mkdir -p ${HOME}/.config/hivemind ${HOME}/.local/share/hivemind \
  && rm -rf ${HOME}/.cache /tmp/requirements.txt

ENV EDITOR=vim

ENTRYPOINT ["sleep", "infinity"]

WORKDIR /home/${USER}
