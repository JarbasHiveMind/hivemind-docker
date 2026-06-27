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
ARG UV_PRERELEASE=allow
ARG USER=hivemind

ENV HIVEMIND_WEBSOCKET_PING_INTERVAL=25 \
    HIVEMIND_WEBSOCKET_PING_TIMEOUT=10

COPY files/requirements.txt /tmp/requirements.txt
COPY files/agent-requirements.txt /tmp/agent-requirements.txt
COPY files/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY files/hivemind_intent_quota_plugin-0.1.0a4-py3-none-any.whl /tmp/hivemind_intent_quota_plugin-0.1.0a4-py3-none-any.whl

USER root

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -o Dpkg::Options::="--force-confold" -y --no-install-recommends --no-install-suggests \
      build-essential python3-dev \
 && PRERELEASE="${UV_PRERELEASE}" \
 && if [ "${ALPHA}" = "true" ]; then PRERELEASE="allow"; fi \
 && if [ -f /run/secrets/github_token ]; then \
      GITHUB_TOKEN="$(cat /run/secrets/github_token)" \
      && git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"; \
    fi \
 && uv pip install --prerelease="${PRERELEASE}" \
      --reinstall-package hivemind-bus-client \
      --reinstall-package hivemind-plugin-manager \
      --reinstall-package hivemind-websocket-protocol \
      --reinstall-package hivemind-core \
      --reinstall-package hivemind-http-protocol \
      --reinstall-package hivemind-mqtt-protocol \
      --reinstall-package hivemind-audio-binary-protocol \
      --reinstall-package hivemind-redis-database \
      -r /tmp/requirements.txt \
 && uv pip install --prerelease="${PRERELEASE}" --no-deps \
      --reinstall-package ovos-bus-client \
      --reinstall-package hivemind-ovos-agent-plugin \
      -r /tmp/agent-requirements.txt \
 && if [ -n "${GITHUB_TOKEN:-}" ]; then \
      git config --global --remove-section url."https://x-access-token:${GITHUB_TOKEN}@github.com/" || true; \
    fi \
 && rm -f /root/.gitconfig \
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

RUN "/home/${USER}/.venv/bin/python" -c "\
import importlib.metadata as metadata, subprocess, sys; \
from hivemind_bus_client.client import HiveMessageBusClient; \
from hivemind_core.service import get_agent_protocol; \
from hivemind_websocket_protocol import HiveMindWebsocketProtocol; \
from packaging.version import Version; \
subprocess.run([sys.executable, '-m', 'pip', 'check'], check=True); \
version = lambda package: metadata.version(package); \
settings = HiveMindWebsocketProtocol(config={})._websocket_ping_settings(); \
assert settings.get('websocket_ping_interval', 0) > 0, 'hivemind-websocket-protocol keepalive is not enabled'; \
assert hasattr(HiveMessageBusClient, '_websocket_keepalive_options'), 'hivemind-bus-client keepalive support is missing'; \
assert Version(version('hivemind-websocket-protocol')) >= Version('0.2.1a3'), 'hivemind-websocket-protocol must be at least 0.2.1a3'; \
assert Version(version('hivemind-bus-client')) >= Version('0.9.2a4'), 'hivemind-bus-client must be at least 0.9.2a4'; \
assert Version('2.0.0a3') <= Version(version('ovos-bus-client')) < Version('3.0.0'), 'ovos-bus-client must remain on the production 2.x line'; \
assert Version(version('hivemind-core')) >= Version('4.6.7a1'), 'hivemind-core must be at least the production 4.6.7a1 release'; \
assert Version(version('hivemind-ovos-agent-plugin')) >= Version('0.3.2a1'), 'hivemind-ovos-agent-plugin must be at least 0.3.2a1'; \
agent_class, _ = get_agent_protocol(); \
assert agent_class.__name__ == 'OVOSAgentProtocol', f'unexpected agent protocol resolved: {agent_class.__name__}'"

USER "$USER"

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"
