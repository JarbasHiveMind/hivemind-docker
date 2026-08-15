# Compose reference

All Compose files share YAML anchors for logging (`x-logging`, json-file driver,
rotation 200 MB / 1 file) and Podman options (`x-podman`, `userns_mode: keep-id`,
`security_opt: label=disable`). Images are pulled from the `smartgic/` registry at
the `${VERSION}` tag.

## `docker-compose.yml` — hub

| Service | Image | Network | Volumes |
| --- | --- | --- | --- |
| `hivemind_listener` | `smartgic/hivemind-listener:${VERSION}` | host | config (hivemind + hivemind-core), share, `hivemind_local_state` |
| `hivemind_cli` | `smartgic/hivemind-cli:${VERSION}` | host | config, share; `depends_on: hivemind_listener` |

`server.conf` goes into the hivemind-core config dir; `identity.json` into the
hivemind config dir (both come from `${HIVEMIND_CONFIG_FOLDER}`).

## `docker-compose.satellite.yml` — voice satellite

| Service | Image | Notes |
| --- | --- | --- |
| `hivemind_satellite` | `smartgic/hivemind-satellite:${VERSION}` | `devices: /dev/snd`; mounts PulseAudio/PipeWire sockets and OVOS model/record/cache volumes. |
| `hivemind_cli` | `smartgic/hivemind-cli:${VERSION}` | management; `depends_on: hivemind_satellite`. |

Identity via `VOICE_SAT_KEY`, `VOICE_SAT_PASSWORD`, `VOICE_SAT_HOST`,
`VOICE_SAT_PORT`. PulseAudio config via `PULSE_SERVER` / `PULSE_COOKIE` and
`XDG_RUNTIME_DIR`.

## `docker-compose.webchat.yml`

| Service | Image | Ports |
| --- | --- | --- |
| `hivemind_webchat` | `smartgic/hivemind-webchat:${VERSION}` | `9090:9090` |

## `docker-compose.matrix-bot.yml`

| Service | Image | Env |
| --- | --- | --- |
| `hivemind_matrix_bot` | `smartgic/hivemind-matrix-bot:${VERSION}` | `MATRIX_BOT_NAME`, `MATRIX_HOST`, `MATRIX_ROOM`, `MATRIX_TOKEN`, plus `VOICE_SAT_*` identity. |

## `docker-compose.chatroom.yml`

| Service | Image | Env |
| --- | --- | --- |
| `hivemind_chatroom` | `smartgic/hivemind-chatroom:${VERSION}` | `SAT_KEY`, `SAT_PASSWORD`, `SAT_HOST`, `SAT_PORT`. |

> The chatroom service reads `SAT_*` variables, while `matrix-bot` and `satellite`
> read `VOICE_SAT_*`. Match the variable names to the Compose file you run.

## Named volumes

| Volume | Used by | Purpose |
| --- | --- | --- |
| `hivemind_local_state` | hub | `~/.local/state/hivemind`. |
| `ovos_models` | satellite | wake-word / precise-lite models. |
| `ovos_listener_records` | satellite | listener recordings. |
| `ovos_tts_cache` | satellite | TTS / OVOS cache. |
