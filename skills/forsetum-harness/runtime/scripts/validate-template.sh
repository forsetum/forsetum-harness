#!/usr/bin/env bash
set -Eeuo pipefail

printf '%s\n' 'WARNING: validate-template.sh is deprecated; use validate-harness.sh.' >&2
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/validate-harness.sh" "$@"
