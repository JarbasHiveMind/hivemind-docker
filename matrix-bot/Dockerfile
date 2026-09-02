# syntax=docker/dockerfile:1.27@sha256:bde3983e9c939224420ddaf6b784cc30e09b035a4dea01f581230c50809f372e
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
ARG OVOS_RELEASES_REF=main

LABEL org.opencontainers.image.title="HiveMind OCI Matrix bot" \
      org.opencontainers.image.description="Connecting in a Matrix chatroom to HiveMind" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-matrix-bot:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      io.openvoiceos.constraints.ref="${OVOS_RELEASES_REF}"

ARG CHANNEL=alpha
ARG UV_PRERELEASE=never
ARG USER=hivemind

# The channel's resolved, mutually-consistent version set from OpenVoiceOS/ovos-releases. ADD
# checksums the remote file, so the layer cache busts exactly when the constraints change.
ADD --chmod=0644 https://raw.githubusercontent.com/OpenVoiceOS/ovos-releases/${OVOS_RELEASES_REF}/constraints-${CHANNEL}.txt /tmp/constraints.txt

COPY files/requirements.txt /tmp/requirements.txt
COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    uv pip install --prerelease="${UV_PRERELEASE}" -c /tmp/constraints.txt -r /tmp/requirements.txt \
 && rm -rf /tmp/* /var/tmp/*

USER "$USER"

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"
