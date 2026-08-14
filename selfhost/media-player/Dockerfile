FROM python:3.12-slim

# Second, isolated hivemind-core instance running the hivemind-media-player
# agent protocol (OCP/audio playback only, no NL query answering).
# Headless box: mpv/vlc have no real audio sink here, that's fine — this
# container exists to prove the OCP message path, not to make sound.

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        mpv vlc ca-certificates curl gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --no-log-init -m -c "HiveMind media player" hivemind \
 && mkdir -p /home/hivemind/.config /home/hivemind/.local/share \
 && chown -R hivemind:hivemind /home/hivemind
USER hivemind
WORKDIR /home/hivemind
ENV PATH=/home/hivemind/.local/bin:$PATH

# Pinned to the current hivemind-core alpha (verified on ser9 — an
# unpinned floor of 4.6.2a1 let the container resolve a stale 4.11.3a1).
RUN pip install --user --pre \
        "hivemind-core>=4.13.9a1" \
        "hivemind-sqlite-database>=0.4.0a2" \
        "hivemind-player-protocol[extras]"

# Seed configs live outside the config volume mount point, so the
# entrypoint can copy them in on first boot without the volume hiding them.
COPY --chown=hivemind:hivemind server.json /home/hivemind/seed/server.json
COPY --chown=hivemind:hivemind mycroft.conf /home/hivemind/seed/mycroft.conf
COPY --chown=hivemind:hivemind entrypoint.sh /home/hivemind/entrypoint.sh
RUN chmod +x /home/hivemind/entrypoint.sh

EXPOSE 5678 5679

ENTRYPOINT ["/home/hivemind/entrypoint.sh"]
