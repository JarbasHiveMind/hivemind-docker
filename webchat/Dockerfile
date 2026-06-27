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

LABEL org.opencontainers.image.title="HiveMind OCI WebChat" \
      org.opencontainers.image.description="Connecting to the HiveMind with javascript reference implementation" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${REGISTRY}/hivemind-base:${TAG}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-webchat:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}"

ARG ALPHA=false
ARG UV_PRERELEASE=disallow
ARG USER=hivemind

COPY files/requirements.txt /tmp/requirements.txt

USER root

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    PRERELEASE="${UV_PRERELEASE}" \
 && if [ "${ALPHA}" = "true" ]; then PRERELEASE="allow"; fi \
 && uv pip install --prerelease="${PRERELEASE}" -r /tmp/requirements.txt \
 && rm -rf /tmp/* /var/tmp/*

USER "$USER"

ENTRYPOINT ["hivemind-webchat"]

WORKDIR "/home/${USER}"

EXPOSE 9090
