ARG TAG=alpha
FROM smartgic/hivemind-sound-base:${TAG}

ARG BUILD_DATE=unknown
ARG VERSION=unknown

LABEL org.opencontainers.image.title="HiveMind Voice Satellite"
LABEL org.opencontainers.image.description="Voice Satellite connect to a HiveMind Listener in order to speak with the Open Voice OS message bus"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.documentation="https://jarbashivemind.github.io/HiveMind-community-docs/"
LABEL org.opencontainers.image.source="https://github.com/JarbasHiveMind/hivemind-docker"
LABEL org.opencontainers.image.vendor="HiveMind"

ARG ALPHA=false
ARG USER=hivemind

ENV DEBIAN_FRONTEND noninteractive

USER root

COPY files/requirements.txt /tmp/requirements.txt
COPY --chmod=0755 files/entrypoint.sh /usr/local/bin/entrypoint.sh

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
    && apt-get install -o Dpkg::Options::="--force-confold" -y --no-install-recommends python3-dev build-essential libasound2-dev libportaudio2 portaudio19-dev libpulse-dev \
    && pip3 install -f 'https://whl.smartgic.io/' tflite_runtime \
    && if [ "${ALPHA}" == "true" ]; then \
    pip3 install -U -r /tmp/requirements.txt --pre; \
    else \
    pip3 install -r /tmp/requirements.txt; \
    fi \
    && mkdir -p /home/${USER}/.config/hivemind,.cache/mycroft,.local/share/{mycroft/listener,.precise-lite/mycroft} \
    && chown ${USER}:${USER} -R /home/${USER} \
    && apt-get --purge remove python3-dev build-essential libasound2-dev portaudio19-dev -y \
    && apt-get --purge autoremove -y \
    && apt-get clean \
    && rm -rf ${HOME}/.cache/pip /var/lib/apt /var/log/{apt,dpkg.log} /tmp/requirements.txt

USER $USER

ENV PATH /home/${USER}/.venv/bin:$PATH
ENV VIRTUAL_ENV /home/${USER}/.venv

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]

WORKDIR /home/${USER}
