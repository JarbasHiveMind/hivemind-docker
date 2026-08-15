group "default" {
  targets = [
    "base",
    "sound-base",
    "listener",
    "cli",
    "chatroom",
    "webchat",
    "matrix-bot",
    "satellite",
  ]
}

group "stack" {
  targets = ["base", "sound-base", "listener"]
}

group "services" {
  targets = [
    "listener",
    "cli",
    "chatroom",
    "webchat",
    "matrix-bot",
    "satellite",
  ]
}

# ---------- Variables (override via env or scripts/bake.sh) ----------
variable "REGISTRY"   { default = "docker.io/smartgic" }
variable "TAG"        { default = "alpha" }
variable "LATEST_TAG" { default = "latest" }
variable "CHANNEL"    { default = "alpha" }
variable "UV_PRERELEASE" { default = "allow" }
variable "VERSION"    { default = "alpha" }
variable "BUILD_DATE" { default = "1970-01-01T00:00:00Z" }
variable "GIT_SHA"    { default = "unknown" }

# ---------- Common settings ----------
target "common" {
  platforms = ["linux/amd64","linux/arm64"]

  args = {
    BUILD_DATE    = "${BUILD_DATE}"
    VERSION       = "${VERSION}"
    CHANNEL       = "${CHANNEL}"
    TAG           = "${TAG}"
    REGISTRY      = "${REGISTRY}"
    GIT_SHA       = "${GIT_SHA}"
    OVOS_CHANNEL  = "${CHANNEL}"
    UV_PRERELEASE = "${UV_PRERELEASE}"
  }

  # SBOM + provenance
  attest = [
    { type = "provenance", mode = "max", inline = true },
    { type = "sbom", inline = true }
  ]
}

# ---------- base (context = ./base) ----------
target "base" {
  inherits   = ["common"]
  context    = "base"
  dockerfile = "Dockerfile"
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-base:${TAG}",
    "${REGISTRY}/hivemind-base:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-base:${TAG}",
  ]
  args = {
    IMAGE_REF = "hivemind-base:${TAG}"
  }

  # Inline cache works with any registry
  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-base:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- sound-base (context = ./sound-base) ----------
target "sound-base" {
  inherits   = ["common"]
  context    = "sound-base"
  dockerfile = "Dockerfile"
  depends_on = ["base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-sound-base:${TAG}",
    "${REGISTRY}/hivemind-sound-base:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-sound-base:${TAG}",
  ]
  # Map Dockerfile's BASE_IMAGE name to locally-built base target
  contexts = {
    "hivemind-base" = "target:base"
  }

  args = {
    BASE_IMAGE = "hivemind-base"
    IMAGE_REF  = "hivemind-sound-base:${TAG}"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-sound-base:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- listener (context = ./listener) ----------
target "listener" {
  inherits   = ["common"]
  context    = "listener"
  dockerfile = "Dockerfile"
  depends_on = ["base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-listener:${TAG}",
    "${REGISTRY}/hivemind-listener:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-listener:${TAG}",
  ]
  contexts = {
    "hivemind-base" = "target:base"
  }

  args = {
    BASE_IMAGE = "hivemind-base"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-listener:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- cli (context = ./cli) ----------
target "cli" {
  inherits   = ["common"]
  context    = "cli"
  dockerfile = "Dockerfile"
  depends_on = ["base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-cli:${TAG}",
    "${REGISTRY}/hivemind-cli:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-cli:${TAG}",
  ]
  contexts = {
    "hivemind-base" = "target:base"
  }

  args = {
    BASE_IMAGE = "hivemind-base"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-cli:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- chatroom (context = ./chatroom) ----------
target "chatroom" {
  inherits   = ["common"]
  context    = "chatroom"
  dockerfile = "Dockerfile"
  depends_on = ["base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-chatroom:${TAG}",
    "${REGISTRY}/hivemind-chatroom:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-chatroom:${TAG}",
  ]
  contexts = {
    "hivemind-base" = "target:base"
  }

  args = {
    BASE_IMAGE = "hivemind-base"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-chatroom:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- webchat (context = ./webchat) ----------
target "webchat" {
  inherits   = ["common"]
  context    = "webchat"
  dockerfile = "Dockerfile"
  depends_on = ["base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-webchat:${TAG}",
    "${REGISTRY}/hivemind-webchat:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-webchat:${TAG}",
  ]
  contexts = {
    "hivemind-base" = "target:base"
  }

  args = {
    BASE_IMAGE = "hivemind-base"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-webchat:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- matrix-bot (context = ./matrix-bot) ----------
target "matrix-bot" {
  inherits   = ["common"]
  context    = "matrix-bot"
  dockerfile = "Dockerfile"
  depends_on = ["base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-matrix-bot:${TAG}",
    "${REGISTRY}/hivemind-matrix-bot:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-matrix-bot:${TAG}",
  ]
  contexts = {
    "hivemind-base" = "target:base"
  }

  args = {
    BASE_IMAGE = "hivemind-base"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-matrix-bot:${TAG}"]
  cache-to   = ["type=inline"]
}

# ---------- satellite (context = ./satellite) ----------
target "satellite" {
  inherits   = ["common"]
  context    = "satellite"
  dockerfile = "Dockerfile"
  depends_on = ["sound-base"]
  tags = TAG == "stable" ? [
    "${REGISTRY}/hivemind-satellite:${TAG}",
    "${REGISTRY}/hivemind-satellite:${LATEST_TAG}",
  ] : [
    "${REGISTRY}/hivemind-satellite:${TAG}",
  ]
  contexts = {
    "hivemind-sound-base" = "target:sound-base"
  }

  args = {
    SOUND_BASE_IMAGE = "hivemind-sound-base"
  }

  cache-from = ["type=registry,ref=${REGISTRY}/hivemind-satellite:${TAG}"]
  cache-to   = ["type=inline"]
}
