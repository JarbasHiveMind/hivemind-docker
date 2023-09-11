FROM debian:bookworm-slim

ARG BUILD_DATE=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="HiveMind OCI base image"
LABEL org.opencontainers.image.description="Used as base layer for other OCI images"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/"
LABEL org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker"
LABEL org.opencontainers.image.vendor="HiveMind"

ARG USER=hivemind

ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
  && apt-get install -y git curl python3-minimal python3-pip python3-venv \
  && c_rehash \
  && useradd --no-log-init $USER -m -c "HiveMind user" \
  && python3 -m venv /home/${USER}/.venv \
  && . /home/${USER}/.venv/bin/activate \
  && mkdir -p /home/${USER}/{.config,.cache,.local/share}/mycroft \
  && chown ${USER}:${USER} -R /home/${USER} \
  && apt-get --purge remove python3-dev build-essential -y \
  && apt-get --purge autoremove -y \
  && apt-get clean \
  && rm -rf ${HOME}/.cache /var/lib/apt /var/log/{apt,dpkg.log}

USER $USER

ENV PATH /home/${USER}/.venv/bin:$PATH
ENV VIRTUAL_ENV /home/${USER}/.venv
