# Deploy

All Compose files live in `compose/`. They reference published images under the
`smartgic/` registry, so deployment does not require a local build.

## Setup

```bash
cd compose
cp .env-example .env
# edit .env (see configuration.md)
```

## Roles

| Compose file | Brings up | Notes |
| --- | --- | --- |
| `docker-compose.yml` | `hivemind_listener` (hub) + `hivemind_cli` | The default hub stack. |
| `docker-compose.satellite.yml` | `hivemind_satellite` + `hivemind_cli` | Needs host audio + identity. |
| `docker-compose.webchat.yml` | `hivemind_webchat` | Browser chat on port 9090. |
| `docker-compose.matrix-bot.yml` | `hivemind_matrix_bot` | Matrix bridge. |
| `docker-compose.chatroom.yml` | `hivemind_chatroom` | Flask chatroom bridge. |

Start a role:

```bash
docker-compose -f docker-compose.yml up -d
docker-compose -f docker-compose.satellite.yml up -d
```

## Networking and ports

Most services run with `network_mode: host`, so they bind directly on the host:

- **Hub (`hivemind_listener`)** — `5678` (WebSocket). The HTTP/audio-binary
  protocols listen on their own ports when enabled.
- **Webchat** — published `9090:9090`.

Because the hub and CLI use host networking, the CLI reaches the hub on
`localhost`.

## Volumes

The hub stack persists config, share, and local state:

- `${HIVEMIND_CONFIG_FOLDER}` → `~/.config/hivemind` and `~/.config/hivemind-core`
  (holds `server.conf` and `identity.json`).
- `${HIVEMIND_SHARE_FOLDER}` → `~/.local/share/hivemind`.
- A named volume `hivemind_local_state` → `~/.local/state/hivemind`.

The satellite additionally mounts the host audio sockets (`/dev/snd`, the
PulseAudio/PipeWire runtime sockets) and named volumes for OVOS models, listener
records, and the TTS cache.

## Management commands

```bash
# follow logs
docker-compose logs -f hivemind_listener

# stop / restart
docker-compose down
docker-compose restart hivemind_listener

# register a satellite client (exec into the CLI container)
docker exec -it ovos_hivemind_cli hivemind-cli add-client
```

(`hivemind-cli` exposes the client management subcommands; the CLI container runs
`sleep infinity` so you exec into it.)

## SSL

The images serve plain WebSocket by default. To expose the hub over TLS, terminate
SSL in front of it with a reverse proxy, or configure `hivemind-core`'s own SSL
options and mount the certificates via the config volume.
