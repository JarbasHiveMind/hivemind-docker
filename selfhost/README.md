# HiveMind self-host stack

A `docker compose` stack that brings up a working HiveMind hub — with a real
OVOS assistant behind it — plus any of the chat/voice bridges, on one
machine. Grounded in the setups verified running on `ser9`
(`~/hivemind-bridges/<name>/`, systemd units under
`~/.config/systemd/user/hivemind-*`): Mattermost, Matrix, and DeltaChat have
had full voice/text round trips there; media-player runs OCP; baresip runs
SIP.

## Quickstart

```sh
cp .env.example .env
# edit .env: fill in a token only for the bridges you enable (see below)
docker compose --profile hub --profile matrix up
```

That starts the hub (hivemind-core + ovos-messagebus + ovos-core +
ovos-audio, with the date-time skill so you get real replies) and the
bundled Matrix homeserver + matrix bridge. Swap `matrix` for any other
profile, or list several: `--profile matrix --profile hackchat`.

On first boot the hub mints a HiveMind client per enabled bridge, whitelists
the message types it needs, and writes its credentials into a Docker volume
the bridge reads from — see "How credentials work" below. No secret ever
goes in this repo or in `.env`, except the external tokens you provide
yourself (Telegram, Twitch).

## Profiles

| Profile | What it starts | External account needed? |
|---|---|---|
| `hub` | hivemind-core + OVOS agent stack (always pulled in by any bridge profile) | no |
| `matrix` | bundled Conduit homeserver + matrix bridge | no (unless you set `MATRIX_HOMESERVER`/`MATRIX_TOKEN` to bridge into an external server) |
| `mattermost` | bundled Mattermost + Postgres + mattermost bridge | no — create a bot account in your own new Mattermost instance after first boot |
| `deltachat` | deltachat bridge | yes — a real (or throwaway, e.g. testrun.org) e-mail account |
| `hackchat` | hackchat bridge | no — anonymous public channel |
| `twitch` | twitch bridge | yes — a Twitch OAuth token for your bot account |
| `telegram` | telegram bridge (built from `JarbasHiveMind/hivemind-telegram-bridge`) | yes — a bot token from @BotFather |
| `baresip` | bundled Asterisk SIP server + baresip bridge | no |
| `media-player` | a second, isolated hub running the OCP/media-player agent (no NL query answering) | no |

## How first-run credential generation works

1. The `hub` container's entrypoint starts the OVOS agent stack, then runs
   `bootstrap/hub-init.sh`.
2. For every bridge named in `HIVEMIND_BRIDGES` (set in
   `docker-compose.yml`), it runs `hivemind-core add-client`, parses the
   generated access key / password from the CLI output, and calls
   `hivemind-core allow-msg` to whitelist `recognizer_loop:utterance` and
   `speak` (plus the `ovos.common_play.*` types for the media-player hub).
3. The result is written to `/creds/<bridge>.env` inside the shared
   `hivemind-creds` Docker volume.
4. Each bridge container's entrypoint (`bootstrap/wait-for-creds.sh`) polls
   for its `<bridge>.env` file, sources it, and only then execs the real
   bridge process with `--access-key`/`--password` (or the bridge's
   equivalent flags).
5. On every later boot, step 2 is skipped for any bridge whose creds file
   already exists — no new clients are minted, no client is re-paired.

This means the *only* thing you ever type into `.env` is an external
service's own token; the HiveMind pairing between hub and bridge is fully
automatic and never touches disk outside the `hivemind-creds` volume (which
you can `docker volume rm` to force a clean re-pair).

**Known gap (TODO, not guessed):** the Matrix bridge's CLI
(`HiveMind-matrix run --help`) takes no `--access-key`/`--password` flags at
all — unlike every other bridge here, it expects a pre-paired
`_identity.json` (an RSA keypair + credentials) at
`$XDG_CONFIG_HOME/hivemind/`. The shared bootstrap above does not generate
that file's keypair yet, so the matrix bridge is not auto-paired; see the
comment in `bridges/matrix/Dockerfile` for the manual pairing step.
Likewise `telegram-bridge`'s upstream Dockerfile (in its own repo) takes
credentials via plain env vars and isn't yet wired to
`wait-for-creds.sh` — set `HIVEMIND_ACCESS_KEY`/`HIVEMIND_PASSWORD` in
`.env` manually for now after reading them out of the `hivemind-creds`
volume (`docker compose run --rm hub cat /creds/telegram.env`).

## Self-hosted infra

- **Matrix**: [Conduit](https://gitlab.com/famedly/conduit), config in
  `infra/conduit.toml` (copied from the verified ser9 setup), loopback-only
  by default (`127.0.0.1:6167`).
- **Mattermost**: official `mattermost-team-edition` image + its own
  Postgres, loopback-only (`127.0.0.1:8065`) — open that URL after first
  boot to create your team and a bot account for the bridge.
- **Asterisk** (SIP, for `baresip`): `andrius/asterisk` image, config in
  `infra/asterisk/` (copied from the verified ser9 setup). Runs on
  `network_mode: host` because SIP/RTP need real UDP ports, matching the
  ser9 unit.

None of these are exposed beyond localhost by default. If you want a bridge
reachable from elsewhere (a public Telegram/Twitch bot, a phone dialing in
over the internet), that's a deliberate choice you make in your own
reverse-proxy / firewall setup — this compose file does not make it for
you.

## Validating without disturbing a running deployment

```sh
docker compose config              # parses the whole stack, catches typos
docker compose build hub matrix-bridge   # build individual images without starting anything
```

Do not `docker compose up` the full stack on a box that already runs any of
these services under their own systemd units (like ser9) — use an isolated
project name and alternate ports if you want an end-to-end smoke test
alongside a live deployment:

```sh
docker compose -p hivemind-smoketest --profile hub --profile hackchat up
```

## Docs per service

- hivemind-core: https://github.com/JarbasHiveMind/HiveMind-core
- Matrix bridge: https://github.com/JarbasHiveMind/HiveMind-matrix-bridge
- Mattermost bridge: https://github.com/JarbasHiveMind/HiveMind_mattermost_bridge
- DeltaChat bridge: https://github.com/JarbasHiveMind/HiveMind-deltachat-bridge
- HackChat bridge: https://github.com/JarbasHiveMind/HiveMind-HackChatBridge
- Twitch bridge: https://github.com/JarbasHiveMind/HiveMind-twitch-bridge
- Telegram bridge: https://github.com/JarbasHiveMind/hivemind-telegram-bridge
- Baresip/SIP bridge: https://github.com/JarbasHiveMind/HiveMind-baresip-bridge
- Community docs: https://jarbashivemind.github.io/HiveMind-community-docs/
