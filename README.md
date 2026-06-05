# hivemind-docker

Docker/Podman images and Compose stacks for running a
[HiveMind](https://github.com/JarbasHiveMind/HiveMind-core) hub or satellite
alongside an [OpenVoiceOS](https://openvoiceos.com) instance. The repository ships
a layered image stack and per-service Compose files; the images themselves
`pip`/`uv pip` install the upstream HiveMind and OVOS packages.

## Where it sits

A HiveMind mesh is a central [hivemind-core](https://github.com/JarbasHiveMind/HiveMind-core)
hub with satellites and bridges connecting to it. This repo containerises those
roles so a hub, a voice satellite, the CLI, and the chat bridges can be brought up
with Compose instead of installed by hand.

## Images

| Image | Role |
| --- | --- |
| `hivemind-base` | Stack root: `python:3.13-slim` + venv + `uv`, non-root `hivemind` user. |
| `hivemind-sound-base` | `base` + audio runtime (PulseAudio/PipeWire/ALSA). |
| `hivemind-listener` | The **hub** — runs `hivemind-core listen` (core + http/audio-binary protocols + redis). |
| `hivemind-satellite` | Voice satellite (`hivemind-voice-sat`) with OVOS STT/TTS/VAD/WW/mic/PHAL. |
| `hivemind-cli` | `HiveMind-cli` + core; exec in to run `hivemind-client`. |
| `hivemind-chatroom`, `hivemind-webchat`, `hivemind-matrix-bot` | Bridge / client surfaces. |

## Prerequisites

- Docker with the Buildx plugin (`docker buildx version`), or a Podman-compatible
  Compose setup. The Compose files include Podman options (`userns_mode: keep-id`).
- A decent internet connection for the first image pull.
- For the satellite: host audio (`/dev/snd`, PulseAudio/PipeWire socket).

## Quickstart — run a hub

The published images live under the `smartgic/` registry, so you can run without
building.

```bash
cd compose
cp .env-example .env
# edit .env — at minimum set the config/share folders and timezone
docker-compose up -d
```

`compose/docker-compose.yml` starts the **hub** (`hivemind_listener`) and the CLI
(`hivemind_cli`). To register a satellite client, exec into the CLI container and
use `hivemind-cli`.

Bring up other roles with their dedicated Compose files:

```bash
docker-compose -f docker-compose.satellite.yml up -d   # voice satellite
docker-compose -f docker-compose.webchat.yml up -d     # browser chat (port 9090)
docker-compose -f docker-compose.matrix-bot.yml up -d  # Matrix bridge
docker-compose -f docker-compose.chatroom.yml up -d    # flask chatroom bridge
```

## Configuration

Runtime config is supplied through `compose/.env` (config/share folders, timezone,
satellite identity, Matrix credentials). `mycroft.conf.example` is a sample OVOS
config for the satellite. See [`docs/configuration.md`](docs/configuration.md) for
the full variable reference and per-service notes.

## Building images

Builds are driven by Docker Buildx Bake (`docker-bake.hcl` + `scripts/bake.sh`).
Plain `docker build` is not supported — base-image wiring relies on Bake contexts.

```bash
./scripts/bake.sh --load --no-push    # local amd64 build into Docker
./scripts/bake.sh -T stack            # build base + sound-base + listener
./scripts/bake.sh --print             # show resolved Bake config, no build
./scripts/bake.sh                      # multi-arch publish (default registry/tag)
```

See [`docs/building.md`](docs/building.md) for targets, variables, and multi-arch
notes.

## Documentation

See [`docs/`](docs/index.md):

- [Deploy](docs/deploy.md) — bring up each role, ports, volumes, management.
- [Compose reference](docs/compose-reference.md) — every Compose file and service.
- [Configuration](docs/configuration.md) — environment variables.
- [Building](docs/building.md) — Buildx Bake targets and variables.

## License

MIT
