# syntax=docker/dockerfile:1.27@sha256:bde3983e9c939224420ddaf6b784cc30e09b035a4dea01f581230c50809f372e
ARG TAG=alpha
ARG REGISTRY=docker.io/smartgic
ARG SOUND_BASE_IMAGE=${REGISTRY}/hivemind-sound-base:${TAG}
FROM ${SOUND_BASE_IMAGE}
ARG TAG
ARG REGISTRY
ARG SOUND_BASE_IMAGE
ARG GIT_SHA=unknown

ARG BUILD_DATE=unknown
ARG VERSION=unknown
ARG OVOS_RELEASES_REF=main

LABEL org.opencontainers.image.title="HiveMind Voice Satellite" \
      org.opencontainers.image.description="Voice Satellite connect to a HiveMind Listener in order to speak with the Open Voice OS message bus" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker" \
      org.opencontainers.image.vendor="HiveMind" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="HiveMind Community" \
      org.opencontainers.image.base.name="${SOUND_BASE_IMAGE}" \
      org.opencontainers.image.url="https://jarbashivemind.github.io/HiveMind-community-docs/" \
      org.opencontainers.image.ref.name="${REGISTRY}/hivemind-satellite:${TAG}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      io.openvoiceos.constraints.ref="${OVOS_RELEASES_REF}"

ARG CHANNEL=alpha
ARG UV_PRERELEASE=never
ARG USER=hivemind

# The channel's resolved, mutually-consistent version set from OpenVoiceOS/ovos-releases. ADD
# checksums the remote file, so the layer cache busts exactly when the constraints change.
ADD --chmod=0644 https://raw.githubusercontent.com/OpenVoiceOS/ovos-releases/${OVOS_RELEASES_REF}/constraints-${CHANNEL}.txt /tmp/constraints.txt

USER root

COPY files/requirements.txt /tmp/requirements.txt
COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,target=/root/.cache/uv,sharing=locked \
    apt-get update \
 && apt-get install -o Dpkg::Options::="--force-confold" -y --no-install-recommends --no-install-suggests \
      libatomic1 libasound2-dev libportaudio2 portaudio19-dev libpulse-dev build-essential python3-dev mpv \
 && uv pip install --prerelease="${UV_PRERELEASE}" -c /tmp/constraints.txt -r /tmp/requirements.txt \
 # precise-onnx needs ovos-plugin-manager>=1, which the stable channel does not have yet
 # (its ovos-audio-plugin-mpv still pins opm<0.10); vosk covers wake word where this skips
 && (uv pip install --prerelease="${UV_PRERELEASE}" -c /tmp/constraints.txt ovos-ww-plugin-precise-onnx \
     || echo "ovos-ww-plugin-precise-onnx unavailable on this channel; vosk wake word remains") \
 && mkdir -p \
      "/home/${USER}/.config/hivemind" \
      "/home/${USER}/.config/mycroft" \
      "/home/${USER}/.cache/mycroft" \
      "/home/${USER}/.local/state/mycroft" \
      "/home/${USER}/.local/share/mycroft/listener" \
      "/home/${USER}/.local/share/precise-lite/mycroft" \
      "/home/${USER}/.local/share/vosk" \
 && chown "${USER}:${USER}" -R "/home/${USER}" \
 && apt-get --purge remove -y libasound2-dev portaudio19-dev libpulse-dev build-essential python3-dev \
 && apt-get --purge autoremove -y \
 && rm -rf /var/log/{apt,dpkg.log} /tmp/* /var/tmp/*

USER "$USER"

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR "/home/${USER}"
