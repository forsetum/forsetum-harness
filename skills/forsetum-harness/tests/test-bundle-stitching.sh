#!/usr/bin/env bash
# A stitching command failure must never produce an apparently successful bundle.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-stitching.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
REAL_AWK="$(command -v awk)"
export REAL_AWK
mkdir "$WORK/bin"
cat >"$WORK/bin/awk" <<'AWK'
#!/usr/bin/env bash
for arg in "$@"; do
  if [[ "$arg" == *"${STITCH_MARKER:?}"* ]]; then
    printf 'injected stitching failure\n' >&2
    exit 73
  fi
done
exec "$REAL_AWK" "$@"
AWK
chmod +x "$WORK/bin/awk"
for marker in MODULE_DOCS_START MODULE_VARS_START MODULE_READINESS_START; do
  set +e
  STITCH_MARKER="$marker" PATH="$WORK/bin:$PATH" bash "$ROOT/scripts/bundle.sh" --lang en --module web-starter --dir "$WORK/$marker" >"$WORK/$marker.log" 2>&1
  status=$?
  set -e
  [[ "$status" != 0 ]] || fail "$marker failure was swallowed"
  [[ ! -e "$WORK/$marker" ]] || fail "$marker failure exported a partial project"
  grep -Fq 'injected stitching failure' "$WORK/$marker.log" || fail "$marker injection did not execute"
  printf 'PASS: %s failure prevents export\n' "$marker"
done

cat >"$WORK/bin/awk" <<'AWK'
#!/usr/bin/env bash
for arg in "$@"; do
  if [[ "$arg" == tbl=* && "$arg" == *$'\n'* ]]; then
    printf 'awk: newline in string\n' >&2
    exit 2
  fi
done
exec "$REAL_AWK" "$@"
AWK
PATH="$WORK/bin:$PATH" bash "$ROOT/scripts/bundle.sh" --lang en --module web-starter --dir "$WORK/portable" >"$WORK/portable.log" 2>&1
for text in '00-overview/architecture.md' '### Module Persona' '### Domain Guardrails'; do
  case "$text" in
    '00-overview/architecture.md') file=docs/INDEX.md ;;
    '### Module Persona') file=docs/08-reference/template-variables.md ;;
    *) file=docs/09-governance/implementation-readiness.md ;;
  esac
  grep -Fq "$text" "$WORK/portable/$file" || fail "portable awk output omitted $text"
done
printf 'PASS: stitching supports awk implementations that reject multiline -v arguments\n'
