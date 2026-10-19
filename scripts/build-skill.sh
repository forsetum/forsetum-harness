#!/usr/bin/env bash
# Build an installable skill directory from canonical product sources.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 2; }
[[ $# == 2 && "$1" == --output && -n "$2" ]] || fail 'Usage: build-skill.sh --output <new-skill-directory>; parent must exist'
requested="$2"
case "$requested" in */|.|..|*/.|*/..) fail 'output must name a new directory' ;; esac
parent="$(dirname -- "$requested")"
[[ -d "$parent" ]] || fail 'output parent must already exist'
# Reject user symlink ancestors; macOS uses standard /tmp and /var aliases.
check="$parent"
while :; do
  if [[ -L "$check" ]]; then
    case "$(uname -s):$check" in Darwin:/tmp|Darwin:/var) ;; *) fail 'output parent must not contain symlinks' ;; esac
  fi
  [[ "$check" != / && "$check" != . ]] || break
  next="$(dirname -- "$check")"
  [[ "$next" != "$check" ]] || break
  check="$next"
done
parent="$(cd -- "$parent" && pwd -P)"
output="$parent/$(basename -- "$requested")"
[[ ! -e "$output" && ! -L "$output" ]] || fail 'output already exists; choose a new directory'
case "$output/" in "$ROOT/template/"*|"$ROOT/scripts/"*|"$ROOT/skills/"*|"$ROOT/.git/"*) fail 'output must not be inside product sources' ;; esac
skill="$ROOT/skills/forsetum-harness"
for source in "$ROOT/template" "$skill/scripts" "$skill/adapters" "$skill/references" "$skill/agents"; do
  [[ -d "$source" ]] || fail "missing package source: $source"
  [[ -z "$(find "$source" -type l -print)" ]] || fail "symlinks are not package sources: $source"
done
[[ -f "$skill/SKILL.md" && ! -L "$skill/SKILL.md" ]] || fail 'missing regular SKILL.md'
work="$(mktemp -d "$parent/.forsetum-build.XXXXXX")"
trap 'rm -rf -- "$work"' EXIT
cp "$skill/SKILL.md" "$work/SKILL.md"
for dir in agents adapters references scripts; do cp -R "$skill/$dir" "$work/$dir"; done
mkdir -p "$work/runtime/scripts"
for name in init bundle validate-harness validate-template; do
  for ext in sh ps1; do
    [[ -f "$ROOT/scripts/$name.$ext" && ! -L "$ROOT/scripts/$name.$ext" ]] || fail "missing regular canonical script: $name.$ext"
    cp "$ROOT/scripts/$name.$ext" "$work/runtime/scripts/"
  done
done
cp -R "$ROOT/template" "$work/runtime/template"
[[ "$(find "$work" -type f -name SKILL.md | wc -l | tr -d ' ')" == 1 ]] || fail 'package must contain exactly one SKILL.md'
# mkdir claims a new path and fails if another process already created it.
# Never remove or overwrite a pre-existing destination, including on failure.
mkdir -- "$output"
cp -R "$work/." "$output/"
printf 'PASS: built installable skill: %s\n' "$output"
