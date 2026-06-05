# Building images

Builds use Docker Buildx Bake (`docker-bake.hcl`) via the `scripts/bake.sh`
wrapper. Plain `docker build` is **not** supported — each child image consumes
`target:base` / `target:sound-base` through Bake contexts.

## Prerequisites

- Docker with Buildx (`docker buildx version` must succeed).
- For cross-arch builds, binfmt/qemu (the wrapper installs `tonistiigi/binfmt`
  automatically unless `--no-binfmt`).

## Targets

Bake groups defined in `docker-bake.hcl`:

| Target | Builds |
| --- | --- |
| `default` | all images |
| `stack` | `base`, `sound-base`, `listener` |
| `services` | `listener`, `cli`, `chatroom`, `webchat`, `matrix-bot`, `satellite` |
| `<name>` | a single image target |

## Common commands

```bash
./scripts/bake.sh --load --no-push     # local amd64 build, load into Docker
./scripts/bake.sh -T stack             # build the stack group
./scripts/bake.sh -T listener          # build one target
./scripts/bake.sh --print              # resolved Bake config, no build
./scripts/bake.sh                       # multi-arch publish (default registry/tag)
./scripts/bake.sh --no-cache-from --load --no-push   # disable registry cache
```

`--load` forces a single-arch `linux/amd64` build and is mutually exclusive with
`--push`.

## Variables / flags

| Flag | Env | Default | Description |
| --- | --- | --- | --- |
| `-r, --registry` | `REGISTRY` | `docker.io/smartgic` | Target registry. |
| `-t, --tag` | `TAG` | `alpha` | Image tag. |
| `--latest-tag` | `LATEST_TAG` | `latest` | Extra tag, applied only when `TAG=stable`. |
| `-v, --version` | `VERSION` | `alpha` | Version label. |
| `-c, --channel` | `CHANNEL` | `alpha` | Release channel. |
| `-p, --platforms` | `PLATFORMS` | `linux/amd64,linux/arm64` | Build platforms (CSV). |
| `-T, --targets` | `TARGETS` | `default` | Bake target(s). |
| `--no-push` | `PUSH=false` | push by default | Build without pushing. |
| `--load` | `LOAD=true` | off | Load into local Docker (amd64 only). |
| `--print` | `PRINT=true` | off | Print resolved config, no build. |
| `--no-cache-from` | `CACHE_FROM=false` | on | Disable registry cache. |
| `--ensure-binfmt` / `--no-binfmt` | `ENSURE_BINFMT` | `auto` | Force/skip binfmt install. |
| `--builder` | `BUILDER` | `hivemind-bake` | Buildx builder name. |

## Notes

- The default publish registry is `docker.io/smartgic`.
- The base image pins Python by digest; bumping it is a manual Dockerfile edit
  (Renovate assists).
