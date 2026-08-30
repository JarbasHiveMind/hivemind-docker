# HiveMind-Docker

Welcome to **HiveMind-Docker**, the quickest way to hive-mind your way into a distributed, multi-instance Open Voice OS setup. This repository is your one-stop shop for running a HiveMind Node or a HiveMind Hub with the power of Docker or Podman. Think of it as the central nervous system for all your Open Voice OS-enabled devices—but with fewer existential crises and more containers.

## Why HiveMind-Docker?

Because managing a distributed AI system should be as easy as ordering takeout! We package everything you need in neat Docker containers so you can:

- Coordinate your Hivemind devices like a boss.
- Avoid dependency nightmares. (Goodbye, "works on my machine!")
- Set up your HiveMind faster than it takes to debug a YAML file.

## Prerequisites

Before you dive into the hive, make sure you have the following:

1. **Docker** installed on your machine.
   - Don't have it? [Get Docker](https://www.docker.com/get-started).
2. **Docker Compose** installed for orchestration.
   - If you’re not orchestrating, what are you even doing?
3. A decent internet connection.
   - Dial-up won’t cut it. Sorry, 1998.

## Getting Started

### 1. Clone the Repository
First, grab this repository from GitHub like a honeybee grabbing nectar:

```bash
git clone https://github.com/JarbasHiveMind/hivemind-docker.git
cd hivemind-docker
```

### 2. Configure Your Environment
Copy the documented template and fill in real values (`compose/.env-example` explains every variable):

```bash
cp compose/.env-example compose/.env
```

Feel free to use "password123" if you enjoy living dangerously. (Don’t do this. Seriously.)

There is one compose file per deployment under `compose/`:

| File | Deployment |
| ---- | ---------- |
| `docker-compose.yml` | the hub — `hivemind-listener` + an admin `hivemind-cli` |
| `docker-compose.satellite.yml` | a voice satellite pointed at a hub, with its own cli |
| `docker-compose.chatroom.yml` | the Flask chatroom bridge |
| `docker-compose.webchat.yml` | the webchat UI |
| `docker-compose.matrix-bot.yml` | the Matrix bridge |

### 3. Run
Pull the published images and start your deployment:

```bash
docker compose --env-file compose/.env -f compose/docker-compose.yml up -d
```

Grab a coffee—or a pint of honey—while Docker works its magic.

## What this repository builds

| Image | What it runs |
| ----- | ------------ |
| [`smartgic/hivemind-base`](https://hub.docker.com/r/smartgic/hivemind-base) | shared Python 3.13 base layer — parent of everything, not meant to run |
| [`smartgic/hivemind-sound-base`](https://hub.docker.com/r/smartgic/hivemind-sound-base) | base + ALSA/PulseAudio/PipeWire audio stack |
| [`smartgic/hivemind-listener`](https://hub.docker.com/r/smartgic/hivemind-listener) | `hivemind-core listen` — the hub satellites connect to (port 5678, healthchecked) |
| [`smartgic/hivemind-cli`](https://hub.docker.com/r/smartgic/hivemind-cli) | admin console with `hivemind-core` + `hivemind-cli` (exec into it) |
| [`smartgic/hivemind-satellite`](https://hub.docker.com/r/smartgic/hivemind-satellite) | `hivemind-voice-sat` with microphone, VAD, wake-word, STT and TTS plugins |
| [`smartgic/hivemind-chatroom`](https://hub.docker.com/r/smartgic/hivemind-chatroom) | chatroom bridge WebUI (port 8985, healthchecked) |
| [`smartgic/hivemind-webchat`](https://hub.docker.com/r/smartgic/hivemind-webchat) | webchat reference client (port 9090, healthchecked) |
| [`smartgic/hivemind-matrix-bot`](https://hub.docker.com/r/smartgic/hivemind-matrix-bot) | Matrix chatroom bridge |

Every Python install inside the images is pinned by the channel's `constraints-<channel>.txt` from [ovos-releases](https://github.com/OpenVoiceOS/ovos-releases) — the same resolved version set ovos-installer and ovos-docker use, so a hub and its satellites always speak matching protocol versions.

## Image Tags

Every image is published for `linux/amd64` and `linux/arm64` under [docker.io/smartgic](https://hub.docker.com/u/smartgic), one tag per channel — the same channels as [ovos-installer](https://github.com/OpenVoiceOS/ovos-installer):

| Tag | Channel | Versions come from |
| --- | ------- | ------------------ |
| `alpha` | pre-releases | `constraints-alpha.txt` in [ovos-releases](https://github.com/OpenVoiceOS/ovos-releases) |
| `testing` | release candidates | `constraints-testing.txt` |
| `stable` | releases | `constraints-stable.txt` |
| `latest` | alias of `stable` | — |

A dated `<channel>-YYYYMMDD` tag is kept for each publish, and every image is also pushed to the GHCR mirror `ghcr.io/jarbashivemind/hivemind-docker` (no pull-rate limit) and signed with cosign. If a container misbehaves after a pull, pin the previous day's dated tag and open an issue.

## Automation

| Workflow | When | What |
| -------- | ---- | ---- |
| PR build | every pull request | dry-builds the images the PR touches, both architectures |
| Publish on push | merge on `dev` | rebuilds + publishes what changed, every channel |
| Publish on constraints change | hourly | rebuilds images whose pinned packages moved in ovos-releases |
| Weekly rebuild | Tuesdays | full rebuild per channel, so base-OS fixes always land |

The workflows are thin callers of ovos-docker's reusable [`build-images.yml@v2.0.2`](https://github.com/OpenVoiceOS/ovos-docker/blob/v2.0.2/.github/workflows/build-images.yml) — the exact CI that builds the ovos-docker images. An image is verified (manifest, per-arch smoke run) before its channel tag moves, published to Docker Hub and the GHCR mirror, cosign-signed, and what each channel was built from is recorded on the `build-state` branch. Verify a signature with:

```bash
cosign verify \
  --certificate-identity-regexp 'github.com/(JarbasHiveMind/hivemind-docker|OpenVoiceOS/ovos-docker)' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  docker.io/smartgic/hivemind-listener:alpha
```

## Build Images (Buildx Bake)

Builds are handled via Docker Buildx Bake (`docker-bake.hcl` and `scripts/bake.sh`). Direct
`docker build` usage is not supported because base image wiring relies on Bake contexts.

### Quick examples

- Local build (amd64 only, loads to local Docker): `./scripts/bake.sh --load --no-push`
- Multi-arch publish (default registry/tag): `./scripts/bake.sh`
- Build a subset: `./scripts/bake.sh -T stack` or `./scripts/bake.sh -T services`
- Inspect resolved Bake config: `./scripts/bake.sh --print`
- Disable registry cache: `./scripts/bake.sh --no-cache-from --load --no-push`

### Configuration

Defaults are defined in `docker-bake.hcl` and `scripts/bake.sh`:

- `REGISTRY` (default `docker.io/smartgic`)
- `TAG` and `VERSION` (default `alpha`)
- `LATEST_TAG` (default `latest`, only applied when `TAG=stable`)
- `CHANNEL` (default `alpha`): which `constraints-<channel>.txt` pins the installs
- `OVOS_RELEASES_REF` (default `main`): git ref of ovos-releases to take the constraints from
- `PLATFORMS` (default `linux/amd64,linux/arm64`)
- `UV_PRERELEASE` (default `allow`): uv prerelease policy (`never` outside alpha)
- `MIRROR_REGISTRY` (default empty; CI uses `ghcr.io/jarbashivemind/hivemind-docker`)
- `CACHE_REPO`/`CACHE_TO`: GHCR build cache (`hivemind-docker-cache`); leave `CACHE_TO` empty locally
- `ENSURE_BINFMT` (default `auto`, set `true` to force or `false` to skip)
- `BUILDER` (default `hivemind-bake`)

## Troubleshooting

1. **Issue: Container won’t start.**
   - Solution: Check the logs with `docker-compose logs`. They’re like a diary for your containers.

2. **Issue: Everything is on fire.**
   - Solution: Stop, drop, and `docker-compose down`.

## Related projects

- [ovos-installer](https://github.com/OpenVoiceOS/ovos-installer) — installs a hub, listener or satellite profile using these images
- [ovos-docker](https://github.com/OpenVoiceOS/ovos-docker) — the Open Voice OS images this hive plugs into
- [HiveMind-core](https://github.com/JarbasHiveMind/HiveMind-core) — the hub these containers run
- [HiveMind-voice-sat](https://github.com/JarbasHiveMind/HiveMind-voice-sat) — the voice satellite client
- [HiveMind community docs](https://jarbashivemind.github.io/HiveMind-community-docs/) — the protocol and architecture

## Contributing

Want to make this hive even sweeter? Fork the repo, make your changes, and submit a pull request. Contributions are welcome, but bad puns are mandatory. 🐝

## License

This project is licensed under the MIT License. Basically, do whatever you want, but don’t sue us when your HiveMind becomes sentient and decides to unionize.

---

### Disclaimer
We’re not responsible for:
- Your HiveMind taking over your smart home.
- AI existential dilemmas.
- Containers running away with your CPU.

Enjoy HiveMind-Docker responsibly. And remember: with great power comes great containerization!
