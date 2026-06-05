# hivemind-docker

Docker/Podman images and Compose stacks for running a HiveMind hub or satellite
alongside an OpenVoiceOS instance.

- [Deploy](deploy.md)
- [Compose reference](compose-reference.md)
- [Configuration](configuration.md)
- [Building](building.md)

## Where it sits

The repo containerises the roles of a [HiveMind](https://github.com/JarbasHiveMind/HiveMind-core)
mesh: the central hub (`hivemind-listener`), a voice satellite, the CLI, and the
chat bridges. Images install upstream HiveMind and OVOS packages — there is no
application source of its own in this repo.

## Layout

- `docker-bake.hcl` — Buildx Bake image definitions.
- `scripts/bake.sh` — Bake wrapper (flag parsing, binfmt/qemu, push/load/print).
- `base/`, `sound-base/` — the image stack roots.
- `listener/`, `satellite/`, `cli/`, `chatroom/`, `webchat/`, `matrix-bot/` — the
  per-role images (`Dockerfile` + `files/`).
- `compose/` — per-service `docker-compose.*.yml` and `.env-example`.
- `mycroft.conf.example` — sample OVOS config for the satellite.
