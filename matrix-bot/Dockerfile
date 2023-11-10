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

RUN if [ "${ALPHA}" == "true" ]; then \
  pip3 install -r /tmp/requirements.txt --pre; \
  else \
  pip3 install -r /tmp/requirements.txt; \
  fi \
  && rm -rf ${HOME}/.cache /tmp/requirements.txt

ENTRYPOINT HiveMind-matrix run --key "$VOICE_SAT_KEY" --password "$VOICE_SAT_PASSWORD" --host "$VOICE_SAT_HOST" --port "$VOICE_SAT_PORT" --botname "$MATRIX_BOT_NAME" --matrixtoken "$MATRIX_TOKEN" --matrixhost "$MATRIX_HOST" --room "$MATRIX_ROOM"

WORKDIR /home/${USER}
