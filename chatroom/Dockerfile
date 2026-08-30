# syntax=docker/dockerfile:1.26@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32
ARG TAG=alpha
ARG REGISTRY=docker.io/smartgic
ARG BASE_IMAGE=${REGISTRY}/hivemind-base:${TAG}
FROM ${BASE_IMAGE}
ARG TAG
ARG REGISTRY
ARG BASE_IMAGE
ARG GIT_SHA=unknown

ARG BUILD_DATE=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="HiveMind OCI Chatroom" \
      org.opencontainers.image.description="This simple WebUI allows you to securely interact with your OpenVoiceOS instance through HiveMind." \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-chatroom:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      io.openvoiceos.constraints.ref="${OVOS_RELEASES_REF}"

ARG CHANNEL=alpha
ARG UV_PRERELEASE=never
ARG OVOS_RELEASES_REF=main
ARG USER=hivemind

# The channel's resolved, mutually-consistent version set from OpenVoiceOS/ovos-releases. ADD
# checksums the remote file, so the layer cache busts exactly when the constraints change.
ADD --chmod=0644 https://raw.githubusercontent.com/OpenVoiceOS/ovos-releases/${OVOS_RELEASES_REF}/constraints-${CHANNEL}.txt /tmp/constraints.txt

COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --prerelease="${UV_PRERELEASE}" -c /tmp/constraints.txt "hivemind-flask-chatroom>=0.1.0" \
 && rm -rf /tmp/* /var/tmp/*

USER "$USER"

HEALTHCHECK --interval=60s --timeout=10s --retries=3 --start-period=30s \
  CMD curl -sf http://127.0.0.1:8985/ > /dev/null || exit 1

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"

EXPOSE 8985
