# Configuration

Runtime configuration is supplied through `compose/.env` (copy from
`compose/.env-example`). Image build configuration is covered in
[building.md](building.md).

## Environment variables

| Variable | Example | Used by |
| --- | --- | --- |
| `VERSION` | `alpha` | Image tag pulled by every service. |
| `TZ` | `America/Montreal` | Container timezone. |
| `HIVEMIND_CONFIG_FOLDER` | `~/hivemind/config` | Host path for hivemind config (`server.conf`, `identity.json`). |
| `HIVEMIND_SHARE_FOLDER` | `~/hivemind/share` | Host path for hivemind share data. |
| `HIVEMIND_USER` | `hivemind` | In-container user (volume mount paths). |
| `HIVEMIND_SITEID` | `voice-sat-1` | Site id for the node. |
| `OVOS_CONFIG_FOLDER` | `~/ovos/config` | Host path for OVOS config (satellite). |
| `XDG_RUNTIME_DIR` | `/run/user/1000` | Audio socket runtime dir (satellite). |
| `VOICE_SAT_KEY` | hex string | Satellite access key. |
| `VOICE_SAT_PASSWORD` | hex string | Satellite password. |
| `VOICE_SAT_HOST` | `ws://192.168.100.55` | Hub address the satellite connects to. |
| `VOICE_SAT_PORT` | `5678` | Hub port. |
| `MATRIX_BOT_NAME` | `hivemind-bot` | Matrix bridge bot name. |
| `MATRIX_HOST` | `https://matrix.org` | Matrix homeserver. |
| `MATRIX_ROOM` | `#hivemind-bots:matrix.org` | Matrix room. |
| `MATRIX_TOKEN` | `syt_XXXX` | Matrix access token. |

> The chatroom service uses `SAT_KEY` / `SAT_PASSWORD` / `SAT_HOST` / `SAT_PORT`
> instead of the `VOICE_SAT_*` names — set whichever the running Compose file
> reads.

## OVOS config

`mycroft.conf.example` is a sample OVOS configuration for the satellite (logging,
language, VAD plugin, hotwords). Copy it into `${OVOS_CONFIG_FOLDER}` as
`mycroft.conf` and adjust.

## Identity provisioning

The satellite/bridge identities (`VOICE_SAT_KEY` / `VOICE_SAT_PASSWORD`) must first
be registered as clients on the hub. Exec into the CLI container and add the client
there before starting the satellite.

## Runtime plugin install

The `satellite` and `listener` entrypoints self-install extra plugins at runtime
from `satellite.list` / `listener.list` (diffed against a `.state` file), so first
boot may pip-install on the device. The `tflite_runtime` install in the satellite
is best-effort.
