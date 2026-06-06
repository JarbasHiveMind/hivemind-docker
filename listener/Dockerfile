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

LABEL org.opencontainers.image.title="HiveMind OCI HiveMind listener" \
      org.opencontainers.image.description="Start listening for HiveMind connections" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${REGISTRY}/hivemind-base:${TAG}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-listener:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}"

ARG ALPHA=false
ARG UV_PRERELEASE=never
ARG USER=hivemind

COPY files/requirements.txt /tmp/requirements.txt
COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

USER root

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    --mount=type=secret,id=github_token,required=false \
    apt-get update \
 && apt-get install -o Dpkg::Options::="--force-confold" -y --no-install-recommends --no-install-suggests \
      build-essential python3-dev \
 && PRERELEASE="${UV_PRERELEASE}" \
 && if [ "${ALPHA}" = "true" ]; then PRERELEASE="allow"; fi \
 && if [ -s /run/secrets/github_token ]; then \
      printf '%s\n' \
        '#!/bin/sh' \
        'case "$1" in' \
        '  *Username*) echo x-access-token ;;' \
        '  *Password*) cat /run/secrets/github_token ;;' \
        'esac' > /tmp/git-askpass \
      && chmod 0700 /tmp/git-askpass \
      && export GIT_ASKPASS=/tmp/git-askpass GIT_TERMINAL_PROMPT=0; \
    fi \
 && uv pip install --prerelease="${PRERELEASE}" -r /tmp/requirements.txt \
 && rm -f /tmp/git-askpass \
 && mkdir -p \
      "/home/${USER}/.config/hivemind" \
      "/home/${USER}/.config/hivemind-core" \
      "/home/${USER}/.local/hivemind" \
      "/home/${USER}/.local/share/hivemind" \
      "/home/${USER}/.local/state/hivemind" \
 && chown "${USER}:${USER}" -R "/home/${USER}" \
 && apt-get --purge remove -y build-essential python3-dev \
 && apt-get --purge autoremove -y \
 && rm -rf /var/log/{apt,dpkg.log} /tmp/* /var/tmp/*

USER "$USER"

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"
