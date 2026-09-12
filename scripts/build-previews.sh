#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${REPO_ROOT}/dist/previews"

mkdir -p "${OUTPUT_DIR}"

printf '==================================================\n'
printf '  Building Static AI Harness Preview Bundles      \n'
printf '==================================================\n\n'

# 1. English Web Starter Bundle
printf '==> Building English Web Starter preview...\n'
"${REPO_ROOT}/scripts/bundle.sh" \
  --lang en \
  --module web-starter \
  --output "${OUTPUT_DIR}/web-starter-en.zip"

# 2. Indonesian Web Starter Bundle
printf '\n==> Building Indonesian Web Starter preview...\n'
"${REPO_ROOT}/scripts/bundle.sh" \
  --lang id \
  --module web-starter \
  --output "${OUTPUT_DIR}/web-starter-id.zip"

printf '\n==================================================\n'
printf '  Preview Bundles Built Successfully!             \n'
printf '==================================================\n'
ls -lh "${OUTPUT_DIR}"/*.zip

printf '\nSHA-256 Checksums:\n'
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${OUTPUT_DIR}"/*.zip
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${OUTPUT_DIR}"/*.zip
fi
