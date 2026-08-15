# syntax=docker/dockerfile:1.7
# sound-base/Dockerfile
# Multi-stage to compile pyalsaaudio without shipping toolchains.

ARG TAG=alpha
ARG REGISTRY=docker.io/smartgic
ARG BASE_IMAGE=${REGISTRY}/hivemind-base:${TAG}

############################
# RUNTIME (final)
############################
FROM ${BASE_IMAGE} AS runtime

ARG TAG
ARG REGISTRY
ARG BASE_IMAGE
ARG BUILD_DATE=unknown
ARG VERSION=unknown
ARG IMAGE_REF=${REGISTRY}/hivemind-sound-base:${TAG}
ARG GIT_SHA=unknown

LABEL org.opencontainers.image.title="HiveMind OCI sound base image" \
      org.opencontainers.image.description="Sound base layer for audio related images" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${IMAGE_REF}" \
      org.opencontainers.image.revision="${GIT_SHA}"

ARG USER=hivemind
USER root
SHELL ["/bin/bash", "-c"]

# Audio runtime ONLY (toolchains live in builder)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
 && apt-get install -o Dpkg::Options::="--force-confold" -y --no-install-recommends --no-install-suggests \
      gpg alsa-utils libasound2-plugins flac libportaudio2 \
      pulseaudio-utils pipewire pipewire-alsa mpg123 music123 \
      sox libsox-fmt-all procps \
 && apt-get --purge autoremove -y \
 && rm -rf /var/log/{apt,dpkg.log} /tmp/* /var/tmp/*

# Pulse client config
COPY files/client.conf /etc/pulse/client.conf

# Ensure expected dirs and audio group membership
RUN mkdir -p "/home/${USER}/.config/mycroft/apps" "/home/${USER}/.config/pulse" \
 && chown "${USER}:${USER}" -R "/home/${USER}" \
 && usermod -a -G audio "$USER"

############################
# BUILDER (temporary toolchains)
############################
FROM ${BASE_IMAGE} AS builder
USER root
SHELL ["/bin/bash", "-c"]

# Build pyalsaaudio wheels against same ABI as runtime
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
      build-essential python3-dev libasound2-dev swig

RUN --mount=type=cache,target=/root/.cache/pip \
    PIP_NO_CACHE_DIR=0 python -m pip wheel pyalsaaudio -w /tmp/wheels

############################
# FINAL assemble
############################
FROM runtime
USER root
SHELL ["/bin/bash", "-c"]

COPY --from=builder /tmp/wheels /tmp/wheels
RUN python -m pip install --no-index --find-links=/tmp/wheels pyalsaaudio \
 && rm -rf /tmp/wheels

ARG USER=hivemind
USER "${USER}"
