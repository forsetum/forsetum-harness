#!/usr/bin/env bash
# Portable package gate. Run with Bash 4+; uses only native shell utilities.
set -Eeuo pipefail
((BASH_VERSINFO[0] >= 4)) || { printf 'FAIL: Bash 4+ required\n' >&2; exit 1; }
ROOT="$(cd -- "${1:-$(dirname -- "${BASH_SOURCE[0]}")/..}" && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/forsetum compatibility.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
MODULES=(web-fullstack landing-page sales-outreach general-office mobile-app cli-automation content-marketing research-analysis web-starter it-infra-ops app-maintenance procurement-tender hr-people-ops education-training supply-chain-logistics event-project-mgmt ui-ux-design content-creator digital-advertising academic-education health-medical construction-civil manufacturing-hse culinary-fnb agribusiness-farming sme-business business-growth)
ids() { awk '/^  "modules": \{/ {active=1;next} active && /^    "[^"]+": \{/ {s=$0;sub(/^    "/,"",s);sub(/".*$/,"",s);print s} active && /^  }/ {exit}' "$1" | LC_ALL=C sort; }
block() { awk -v wanted="$2" '/^    "[^"]+": \{/ {s=$0;sub(/^    "/,"",s);sub(/".*$/,"",s);active=(s==wanted)} active {print} active && /^    }/ {exit}' "$1"; }
block_has_top_level_tier() {
  awk '
    function brace_delta(line, i, ch, escaped, in_string, delta) {
      escaped=0; in_string=0; delta=0
      for (i=1; i<=length(line); i++) {
        ch=substr(line,i,1)
        if (in_string) {
          if (escaped) escaped=0
          else if (ch == "\\") escaped=1
          else if (ch == "\"") in_string=0
        } else if (ch == "\"") in_string=1
        else if (ch == "{") delta++
        else if (ch == "}") delta--
      }
      return delta
    }
    NR == 1 { depth=brace_delta($0); next }
    depth == 1 && /^[[:space:]]*"tier"[[:space:]]*:/ { found=1; exit }
    { depth+=brace_delta($0) }
    END { exit(found ? 0 : 1) }
  '
}
fingerprint() { (cd "$1"; find . -type f -print | LC_ALL=C sort | while IFS= read -r file; do cksum "$file"; done; find . -print | LC_ALL=C sort); }
expected="$(printf '%s\n' "${MODULES[@]}" | LC_ALL=C sort)"
printf 'OS: '; uname -a
printf 'Bash: %s\nRoot: %s\n' "$BASH_VERSION" "$ROOT"
INSTALLED="$WORK/installed skill"
mkdir -p "$INSTALLED"
cp -R "$ROOT/skills/forsetum-harness/." "$INSTALLED/"
if [[ ! -d "$INSTALLED/runtime" ]]; then
  # Canonical checkout: materialize the same self-contained installation layout.
  [[ -f "$ROOT/scripts/export-public.sh" ]] || fail 'public package is missing installed runtime'
  mkdir -p "$INSTALLED/runtime/scripts"
  cp -R "$ROOT/template" "$INSTALLED/runtime/template"
  for name in init bundle validate-harness validate-template; do
    cp "$ROOT/scripts/$name.sh" "$ROOT/scripts/$name.ps1" "$INSTALLED/runtime/scripts/"
  done
fi
RUNTIME="$INSTALLED/runtime"
for name in init bundle validate-harness validate-template; do
  for extension in sh ps1; do
    cmp -s "$ROOT/scripts/$name.$extension" "$RUNTIME/scripts/$name.$extension" || fail "runtime script drift: $name.$extension"
  done
done
cases=0
for lang in en id; do
  bash "$RUNTIME/scripts/validate-harness.sh" --template "$lang"
  bash "$RUNTIME/scripts/validate-template.sh" --template "$lang"
  manifest="$ROOT/template/$lang/manifest.json"
  [[ "$(ids "$manifest")" == "$expected" ]] || fail "$lang inventory must contain the approved 27 modules"
  directories="$(find "$ROOT/template/$lang/modules" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | LC_ALL=C sort)"
  [[ "$directories" == "$expected" ]] || fail "$lang module directories must match the approved 27 modules"
  diff -r "$ROOT/template/$lang" "$RUNTIME/template/$lang" >/dev/null || fail "$lang runtime template drift"
  for module in "${MODULES[@]}"; do
    metadata="$(block "$manifest" "$module")"
    for field in name category description directory variables readiness_checks persona interview_phases domain_guardrails; do
      [[ "$metadata" == *"\"$field\":"* ]] || fail "$lang/$module missing metadata: $field"
    done
    ! block_has_top_level_tier <<<"$metadata" || fail "$lang/$module contains commercial tier metadata"
    init_target="$WORK/$lang/$module/init target"
    bundle_target="$WORK/$lang/$module/bundle target"
    bash "$RUNTIME/scripts/init.sh" --lang "$lang" --module "$module" --name 'Compatibility Fixture' --target "$init_target" >/dev/null
    bash "$RUNTIME/scripts/bundle.sh" --lang "$lang" --module "$module" --name 'Compatibility Fixture' --dir "$bundle_target" >/dev/null
    for target in "$init_target" "$bundle_target"; do
      [[ -s "$target/AGENTS.md" && -s "$target/docs/INDEX.md" ]] || fail "$lang/$module output missing"
      ! grep -Fq '{{PROJECT_NAME}}' "$target/AGENTS.md" || fail "$lang/$module name not interpolated"
      while IFS= read -r source; do
        relative="${source#"$ROOT/template/$lang/modules/$module/"}"
        [[ -f "$target/$relative" ]] || fail "$lang/$module overlay missing: $relative"
      done < <(find "$ROOT/template/$lang/modules/$module" -type f -print)
    done
    diff -r "$init_target" "$bundle_target" >/dev/null || fail "$lang/$module init/bundle mismatch"
    cases=$((cases + 1))
    printf 'PASS: %s/%s init and bundle\n' "$lang" "$module"
  done
done
[[ "$cases" == 54 ]] || fail "expected 54 cases, observed $cases"
target="$WORK/conflict target"
mkdir -p "$target/docs"
printf 'keep agents\n' >"$target/AGENTS.md"
printf 'keep docs\n' >"$target/docs/existing.md"
before="$(fingerprint "$target")"
set +e
preview="$(bash "$INSTALLED/scripts/inspect-repository.sh" --target "$target" --lang en --module web-starter 2>&1)"
status=$?
set -e
[[ "$status" == 3 && "$preview" == *'STATE=CONFLICT_REVIEW'* ]] || fail 'installed conflict inspector did not stop'
[[ "$(fingerprint "$target")" == "$before" ]] || fail 'inspector changed target'
for decision in CANCEL PRESERVE SKIP DEFER; do
  output="$(bash "$INSTALLED/scripts/decision-handoff.sh" --decision "$decision" --target "$target" --lang en --module web-starter --initializer "$RUNTIME/scripts/init.sh" --validator "$RUNTIME/scripts/validate-harness.sh")"
  [[ "$output" == *'Mutation: none'* ]] || fail "$decision did not decline mutation"
  [[ "$(fingerprint "$target")" == "$before" ]] || fail "$decision changed target"
done
set +e
bash "$INSTALLED/scripts/decision-handoff.sh" --decision APPROVE_REPLACE_WITH_BACKUP --target "$target" --lang en --module web-starter --initializer "$RUNTIME/scripts/init.sh" --validator "$RUNTIME/scripts/validate-harness.sh" >"$WORK/rejected.log" 2>&1
status=$?
set -e
[[ "$status" == 2 ]] || fail 'incomplete approval must be rejected'
[[ "$(fingerprint "$target")" == "$before" ]] || fail 'rejected approval changed target'
printf 'PASS: installed conflict, cancellation, preservation and incomplete approval safety\nPASS: 54 language/module cases; 108 initializer/bundler executions\n'
