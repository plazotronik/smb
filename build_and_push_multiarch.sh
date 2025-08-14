#!/usr/bin/env bash
set -euo pipefail

# ==== PRECONF ====
IMAGE_NAME="plazotronik/smb"
REPO_URL="https://github.com/plazotronik/smb.git"
WORKDIR="$(pwd)/smb-build"

if [ $# -lt 1 ]; then
  echo "Use: $0 <full_version>"
  echo "Example: $0 4.21.4"
  exit 1
fi

VERSION_FULL="$1"
VERSION_MAJOR="${VERSION_FULL%%.*}"
VERSION_MINOR="${VERSION_FULL%.*}"
TAGS=("$VERSION_FULL" "$VERSION_MINOR" "$VERSION_MAJOR" "latest")

# ==== CLONE ====
rm -rf "$WORKDIR"
git clone --depth=1 "$REPO_URL" "$WORKDIR"
cd "$WORKDIR"

# ==== BUILD ARM, ARM64, AMD64 ====
docker buildx build \
  --force-rm \
  --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
  -f Dockerfile \
  -t docker.io/${IMAGE_NAME}:${VERSION_FULL} \
  -t docker.io/${IMAGE_NAME}:${VERSION_MAJOR} \
  -t docker.io/${IMAGE_NAME}:${VERSION_MINOR} \
  -t docker.io/${IMAGE_NAME}:latest \
  --push \
  .

echo "Multi-arch tags '${TAGS[*]}' published"
