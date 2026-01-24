# syntax=docker/dockerfile:1.7
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
      org.opencontainers.image.base.name="${REGISTRY}/hivemind-base:${TAG}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-chatroom:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}"

ARG ALPHA=false
ARG UV_PRERELEASE=never
ARG USER=hivemind

COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    PRERELEASE="${UV_PRERELEASE}" \
 && if [ "${ALPHA}" = "true" ]; then PRERELEASE="allow"; fi \
 && uv pip install --prerelease="${PRERELEASE}" hivemind-flask-chatroom \
 && rm -rf /tmp/* /var/tmp/*

USER "$USER"

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"

EXPOSE 8985
