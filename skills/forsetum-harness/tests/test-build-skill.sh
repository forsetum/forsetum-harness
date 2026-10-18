#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-builder.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
builder="$ROOT/scripts/build-skill.sh"
[[ -f "$builder" ]] || fail 'native skill builder is missing'
installed="$WORK/installed skill"
(cd / && bash "$builder" --output "$installed")
[[ "$(find "$installed" -type f -name SKILL.md | wc -l | tr -d ' ')" == 1 ]] || fail 'package must contain one discoverable entrypoint'
for name in init bundle validate-harness validate-template; do
  for ext in sh ps1; do
    cmp "$ROOT/scripts/$name.$ext" "$installed/runtime/scripts/$name.$ext" || fail 'runtime script drift'
  done
done
for lang in en id; do diff -r "$ROOT/template/$lang" "$installed/runtime/template/$lang" >/dev/null || fail 'runtime template drift'; done
printf 'sentinel\n' >"$installed/sentinel"
if bash "$builder" --output "$installed" >"$WORK/rejected.log" 2>&1; then fail 'existing output accepted'; fi
[[ "$(cat "$installed/sentinel")" == sentinel ]] || fail 'existing output changed'
for path in / "$ROOT" "$ROOT/template/new-package" "$ROOT/skills/forsetum-harness/new-package" "$WORK/missing/child"; do
  if bash "$builder" --output "$path" >"$WORK/rejected.log" 2>&1; then fail "unsafe path accepted: $path"; fi
done
mkdir "$WORK/real"
ln -s "$WORK/real" "$WORK/link"
if bash "$builder" --output "$WORK/link/package" >"$WORK/rejected.log" 2>&1; then fail 'symlink ancestor accepted'; fi
[[ ! -e "$WORK/real/package" ]] || fail 'symlink path caused mutation'
if bash "$builder" >"$WORK/rejected.log" 2>&1; then fail 'implicit output accepted'; fi
if bash "$builder" --output "$WORK/trailing/.." >"$WORK/rejected.log" 2>&1; then fail 'parent path accepted'; fi
printf 'PASS: native package build, runtime parity, create-only and path safety\n'
