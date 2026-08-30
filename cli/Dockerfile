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

LABEL org.opencontainers.image.title="HiveMind OCI CLI image" \
      org.opencontainers.image.description="Command line to interact with HiveMind" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${BASE_IMAGE}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-cli:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      io.openvoiceos.constraints.ref="${OVOS_RELEASES_REF}"

ARG CHANNEL=alpha
ARG UV_PRERELEASE=never
ARG OVOS_RELEASES_REF=main
ARG USER=hivemind

# The channel's resolved, mutually-consistent version set from OpenVoiceOS/ovos-releases. ADD
# checksums the remote file, so the layer cache busts exactly when the constraints change.
ADD --chmod=0644 https://raw.githubusercontent.com/OpenVoiceOS/ovos-releases/${OVOS_RELEASES_REF}/constraints-${CHANNEL}.txt /tmp/constraints.txt

COPY files/requirements.txt /tmp/requirements.txt

USER root

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
      vim nano python3-dev build-essential libxml2-dev libxslt1-dev \
 && uv pip install --prerelease="${UV_PRERELEASE}" -c /tmp/constraints.txt -r /tmp/requirements.txt \
 && mkdir -p \
      "/home/${USER}/.config/hivemind" \
      "/home/${USER}/.local/share/hivemind-core" \
      "/home/${USER}/.local/state/hivemind" \
      "/home/${USER}/stdout" \
      /var/log/hivemind \
 && chown "${USER}:${USER}" -R "/home/${USER}" /var/log/hivemind \
 && apt-get --purge remove -y python3-dev build-essential libxml2-dev libxslt1-dev \
 && apt-get --purge autoremove -y \
 && rm -rf /var/log/{apt,dpkg.log} /tmp/* /var/tmp/*

USER "$USER"

ENV EDITOR=vim
ENV TERM=linux

ENTRYPOINT ["sleep", "infinity"]

WORKDIR "/home/${USER}"
