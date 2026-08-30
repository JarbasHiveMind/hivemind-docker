# The self-host hub: hivemind-core (current alpha) + a minimal OVOS agent
# stack (messagebus, core, audio) so bridges get real assistant replies,
# not just an echo. Grounded in the OVOS agent_protocol wiring verified on
# ser9's hub (hivemind-core + hivemind-ovos-agent-plugin talking to a local
# ovos-messagebus).
FROM python:3.12-slim@sha256:09f7da3bc104798d0afb40bc08d23ab2da20a76130cec1f2ef170848f5d85217

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --no-log-init -m -c "HiveMind selfhost hub" hivemind
USER hivemind
WORKDIR /home/hivemind
ENV PATH=/home/hivemind/.local/bin:$PATH

# --pre / explicit alpha floor: this is the current alpha line, matching
# the verified ser9 hub. Pin the floor, never a lockfile (see repo
# CLAUDE.md: NO lockfiles, always-latest-prerelease within the floor).
RUN pip install --user --pre \
        "hivemind-core>=4.13.9a1" \
        "hivemind-ovos-agent-plugin>=0.3.6a1" \
        "hivemind-sqlite-database" \
        "ovos-messagebus" \
        "ovos-core[skills-essential]" \
        "ovos-audio" \
        "ovos-tts-plugin-server" \
        "ovos-skill-date-time"

# build context is selfhost/ (see docker-compose.yml: context: ., dockerfile: hub/Dockerfile)
COPY --chown=hivemind:hivemind hub/server.json /home/hivemind/seed/server.json
COPY --chown=hivemind:hivemind hub/mycroft.conf /home/hivemind/seed/mycroft.conf
COPY --chown=hivemind:hivemind hub/entrypoint.sh /home/hivemind/entrypoint.sh
COPY --chown=hivemind:hivemind bootstrap/hub-init.sh /home/hivemind/bootstrap/hub-init.sh
RUN chmod +x /home/hivemind/entrypoint.sh /home/hivemind/bootstrap/hub-init.sh

EXPOSE 5678 8181

ENTRYPOINT ["/home/hivemind/entrypoint.sh"]
