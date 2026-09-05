# syntax=docker/dockerfile:1.27@sha256:bde3983e9c939224420ddaf6b784cc30e09b035a4dea01f581230c50809f372e
# One reference for FROM and the base.name label, so a Renovate bump updates both.
ARG PYTHON_IMAGE=python:3.13.15-slim-trixie@sha256:9d2e5553305c7c7b0097999bb17187c69b921ccd6bc9d40e4bb5ebe652c00285
FROM ${PYTHON_IMAGE}
ARG PYTHON_IMAGE

ARG BUILD_DATE=unknown
ARG CHANNEL=alpha
ARG VERSION=unknown
ARG IMAGE_REF=hivemind-base:alpha
ARG GIT_SHA=unknown
ARG OVOS_RELEASES_REF=main

LABEL org.opencontainers.image.title="HiveMind OCI base image" \
      org.opencontainers.image.description="Used as base layer for other OCI images" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${PYTHON_IMAGE}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${IMAGE_REF}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      io.openvoiceos.constraints.ref="${OVOS_RELEASES_REF}"

ARG USER=hivemind
ARG USER_UID=1000
ARG USER_GID=1000

# uv as a pinned static binary (Renovate tracks the image reference); no unpinned "pip install uv"
COPY --from=ghcr.io/astral-sh/uv:0.12.10@sha256:2bb3ebca0a796a155094a27773d290c4b074572e6107f171d88d086682fd2500 /uv /uvx /usr/local/bin/

# MALLOC_ARENA_MAX=2: the services are heavily threaded; fewer glibc arenas means less RSS on small devices.
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    MALLOC_ARENA_MAX=2

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    printf '%s\n' \
      'path-exclude=/usr/share/doc/*' \
      'path-exclude=/usr/share/man/*' \
      'path-exclude=/usr/share/locale/*' \
      'path-include=/usr/share/locale/locale.alias' \
      > /etc/dpkg/dpkg.cfg.d/99no-docs \
 && apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
      ca-certificates git curl \
 && apt-get --purge autoremove -y \
 && rm -rf /usr/share/doc/* /usr/share/man/* \
 && if [ -d /usr/share/locale ]; then \
      find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name locale.alias -exec rm -rf {} +; \
    fi \
 && rm -rf /var/log/{apt,dpkg.log} /tmp/* /var/tmp/*

# The venv keeps the pip bundled with the (digest-pinned) Python image. setuptools is still needed
# at runtime by packages using pkg_resources; pinned like ovos-installer does (setuptools<82).
# Bytecode is compiled at install time (UV_COMPILE_BYTECODE) so services start fast on small
# devices; PYTHONDONTWRITEBYTECODE keeps the running container from writing .pyc files.
RUN --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    groupadd --gid "$USER_GID" "$USER" \
 && useradd --no-log-init --uid "$USER_UID" --gid "$USER_GID" -m -c "HiveMind user" "$USER" \
 && python -m venv "/home/${USER}/.venv" \
 && source "/home/${USER}/.venv/bin/activate" \
 && uv pip install "setuptools<82" \
 && mkdir -p "/home/${USER}"/.{config,cache,local/{state,share}}/{hivemind,hivemind-core,mycroft} \
 && chown "${USER}:${USER}" -R "/home/${USER}"

USER "$USER"

ENV HIVEMIND_CHANNEL="$CHANNEL" \
    OVOS_CHANNEL="$CHANNEL" \
    IS_OVOS_CONTAINER=true \
    PATH="/home/${USER}/.venv/bin:$PATH" \
    VIRTUAL_ENV="/home/${USER}/.venv"
