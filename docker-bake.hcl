# docker-bake.hcl — HiveMind container images
#
#   ./scripts/bake.sh                       multi-arch build + push of the "default" group
#   ./scripts/bake.sh -T listener --load    local single-arch build of one target
#   docker buildx bake --print services     show the resolved configuration of a group
#
# Image graph:
#   base ─┬─ sound-base ─ satellite
#         └─ listener, cli, chatroom, webchat, matrix-bot

# ---------- Variables (override via env or scripts/bake.sh) ----------
variable "REGISTRY"          { default = "docker.io/smartgic" }
variable "TAG"               { default = "alpha" }
variable "LATEST_TAG"        { default = "latest" }
variable "CHANNEL"           { default = "alpha" }
variable "UV_PRERELEASE"     { default = "allow" }
variable "VERSION"           { default = "alpha" }
variable "BUILD_DATE"        { default = "1970-01-01T00:00:00Z" }
variable "GIT_SHA"           { default = "unknown" }
# Git ref (branch, tag or commit SHA) of OpenVoiceOS/ovos-releases to take constraints-${CHANNEL}.txt from.
# Passing a commit SHA makes the build reproducible and busts the layer cache when the constraints change.
variable "OVOS_RELEASES_REF" { default = "main" }

# Build cache. Lives on GHCR (no pull-rate limits, free for public repositories) as one tag per
# image and TAG, so channels and architectures never share cache entries. CACHE_TO="max" exports
# the cache after the build (CI); leave it empty for local builds without GHCR write access —
# cache-from still works anonymously because the cache package is public.
variable "CACHE_REPO" { default = "ghcr.io/jarbashivemind/hivemind-docker-cache" }
variable "CACHE_TO"   { default = "" }

# Optional second registry every image is also pushed to (CI uses ghcr.io/jarbashivemind/hivemind-docker,
# sub-namespaced so the packages can never collide with the ones other JarbasHiveMind repositories
# publish). The pipeline reads manifests, labels and SBOMs from there, which has no pull-rate limit;
# users keep pulling from REGISTRY. Empty = single registry (local builds).
variable "MIRROR_REGISTRY" { default = "" }

# ---------- Helpers ----------
# stable is additionally tagged LATEST_TAG; every other TAG is published as-is.
# With MIRROR_REGISTRY set, the same tags are also produced for the mirror.
function "tags" {
  params = [image]
  result = compact(concat(
    TAG == "stable" ? [
      "${REGISTRY}/${image}:${TAG}",
      "${REGISTRY}/${image}:${LATEST_TAG}",
    ] : [
      "${REGISTRY}/${image}:${TAG}",
    ],
    MIRROR_REGISTRY == "" ? [""] : (TAG == "stable" ? [
      "${MIRROR_REGISTRY}/${image}:${TAG}",
      "${MIRROR_REGISTRY}/${image}:${LATEST_TAG}",
    ] : [
      "${MIRROR_REGISTRY}/${image}:${TAG}",
    ]),
  ))
}

function "cache_from" {
  params = [image]
  result = ["type=registry,ref=${CACHE_REPO}:${image}-${TAG}"]
}

function "cache_to" {
  params = [image]
  result = compact([CACHE_TO == "" ? "" : "type=registry,ref=${CACHE_REPO}:${image}-${TAG},mode=${CACHE_TO}"])
}

# ---------- Groups ----------
group "default"  { targets = ["stack", "services"] }
group "stack"    { targets = ["base", "sound-base", "listener"] }
group "services" { targets = ["listener", "cli", "chatroom", "webchat", "matrix-bot", "satellite"] }

# ---------- Common settings ----------
target "common" {
  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    BUILD_DATE        = "${BUILD_DATE}"
    VERSION           = "${VERSION}"
    CHANNEL           = "${CHANNEL}"
    TAG               = "${TAG}"
    REGISTRY          = "${REGISTRY}"
    GIT_SHA           = "${GIT_SHA}"
    OVOS_CHANNEL      = "${CHANNEL}"
    UV_PRERELEASE     = "${UV_PRERELEASE}"
    OVOS_RELEASES_REF = "${OVOS_RELEASES_REF}"
  }

  # SBOM + provenance, embedded in the image index
  attest = [
    { type = "provenance", mode = "max", inline = true },
    { type = "sbom", inline = true },
  ]
}

# ---------- Base images ----------
target "base" {
  inherits   = ["common"]
  context    = "base"
  tags       = tags("hivemind-base")
  args       = { IMAGE_REF = "hivemind-base:${TAG}" }
  cache-from = cache_from("hivemind-base")
  cache-to   = cache_to("hivemind-base")
}

target "sound-base" {
  inherits   = ["common"]
  context    = "sound-base"
  contexts   = { "hivemind-base" = "target:base" }
  tags       = tags("hivemind-sound-base")
  args       = { BASE_IMAGE = "hivemind-base", IMAGE_REF = "hivemind-sound-base:${TAG}" }
  cache-from = cache_from("hivemind-sound-base")
  cache-to   = cache_to("hivemind-sound-base")
}

# ---------- Services ----------
target "listener" {
  inherits   = ["common"]
  context    = "listener"
  contexts   = { "hivemind-base" = "target:base" }
  tags       = tags("hivemind-listener")
  args       = { BASE_IMAGE = "hivemind-base" }
  cache-from = cache_from("hivemind-listener")
  cache-to   = cache_to("hivemind-listener")
}

target "cli" {
  inherits   = ["common"]
  context    = "cli"
  contexts   = { "hivemind-base" = "target:base" }
  tags       = tags("hivemind-cli")
  args       = { BASE_IMAGE = "hivemind-base" }
  cache-from = cache_from("hivemind-cli")
  cache-to   = cache_to("hivemind-cli")
}

target "chatroom" {
  inherits   = ["common"]
  context    = "chatroom"
  contexts   = { "hivemind-base" = "target:base" }
  tags       = tags("hivemind-chatroom")
  args       = { BASE_IMAGE = "hivemind-base" }
  cache-from = cache_from("hivemind-chatroom")
  cache-to   = cache_to("hivemind-chatroom")
}

target "webchat" {
  inherits   = ["common"]
  context    = "webchat"
  contexts   = { "hivemind-base" = "target:base" }
  tags       = tags("hivemind-webchat")
  args       = { BASE_IMAGE = "hivemind-base" }
  cache-from = cache_from("hivemind-webchat")
  cache-to   = cache_to("hivemind-webchat")
}

target "matrix-bot" {
  inherits   = ["common"]
  context    = "matrix-bot"
  contexts   = { "hivemind-base" = "target:base" }
  tags       = tags("hivemind-matrix-bot")
  args       = { BASE_IMAGE = "hivemind-base" }
  cache-from = cache_from("hivemind-matrix-bot")
  cache-to   = cache_to("hivemind-matrix-bot")
}

target "satellite" {
  inherits   = ["common"]
  context    = "satellite"
  contexts   = { "hivemind-sound-base" = "target:sound-base" }
  tags       = tags("hivemind-satellite")
  args       = { SOUND_BASE_IMAGE = "hivemind-sound-base" }
  cache-from = cache_from("hivemind-satellite")
  cache-to   = cache_to("hivemind-satellite")
}
