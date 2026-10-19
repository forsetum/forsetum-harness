#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd -- "${SKILL_DIR}/../.." && pwd)"
LAYOUT="${SKILL_DIR}/references/public-package-layout.md"


fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "required contract file is missing: ${1#${REPO_ROOT}/}"
}

require_literal() {
  local path="$1"
  local value="$2"
  grep -Fqx -- "$value" "$path" || fail "expected exact contract line '$value' in ${path#${REPO_ROOT}/}"
}

require_file "$LAYOUT"


require_literal "$LAYOUT" 'discoverable_entrypoint: skills/forsetum-harness/SKILL.md'
require_literal "$LAYOUT" 'bundled_inspector: skills/forsetum-harness/scripts/inspect-repository.sh'
require_literal "$LAYOUT" 'bundled_decision_handoff_bash: skills/forsetum-harness/scripts/decision-handoff.sh'
require_literal "$LAYOUT" 'bundled_decision_handoff_powershell: skills/forsetum-harness/scripts/decision-handoff.ps1'
require_literal "$LAYOUT" 'runtime_root: skills/forsetum-harness/runtime'
require_literal "$LAYOUT" 'runtime_scripts: skills/forsetum-harness/runtime/scripts'
require_literal "$LAYOUT" 'runtime_templates: skills/forsetum-harness/runtime/template/{id,en}'
require_literal "$LAYOUT" 'runtime_resolution: package-relative'
require_literal "$LAYOUT" 'source_checkout_fallback: canonical-root-only'
require_literal "$LAYOUT" 'installed_dependencies: none'
require_literal "$LAYOUT" 'network_fetch_at_runtime: forbidden'
require_literal "$LAYOUT" 'cwd_dependency: forbidden'
require_literal "$LAYOUT" 'private_checkout_dependency: forbidden'

for mapping in \
  'skills/forsetum-harness/SKILL.md <- skills/forsetum-harness/SKILL.md' \
  'skills/forsetum-harness/scripts/inspect-repository.sh <- skills/forsetum-harness/scripts/inspect-repository.sh' \
  'skills/forsetum-harness/runtime/scripts/init.sh <- scripts/init.sh' \
  'skills/forsetum-harness/runtime/scripts/init.ps1 <- scripts/init.ps1' \
  'skills/forsetum-harness/runtime/scripts/bundle.sh <- scripts/bundle.sh' \
  'skills/forsetum-harness/runtime/scripts/bundle.ps1 <- scripts/bundle.ps1' \
  'skills/forsetum-harness/runtime/scripts/validate-harness.sh <- scripts/validate-harness.sh' \
  'skills/forsetum-harness/runtime/scripts/validate-harness.ps1 <- scripts/validate-harness.ps1' \
  'skills/forsetum-harness/runtime/scripts/validate-template.sh <- scripts/validate-template.sh' \
  'skills/forsetum-harness/runtime/scripts/validate-template.ps1 <- scripts/validate-template.ps1' \
  'skills/forsetum-harness/runtime/template/id/ <- canonical template/id/ (27 approved modules)' \
  'skills/forsetum-harness/runtime/template/en/ <- canonical template/en/ (27 approved modules)'; do
  require_literal "$LAYOUT" "${mapping}"
done

# A discoverable package must route all approved profiles, not only ship files.
manifest_ids=$(awk '
  /^  "modules": \{/ { inside=1; next }
  inside && /^  \},?$/ { exit }
  inside && /^    "[^"]+": \{/ { gsub(/^    "|": \{$/, ""); print }
' "$REPO_ROOT/template/en/manifest.json" | LC_ALL=C sort)
catalog_ids=$(sed -nE 's/^\| `([^`]+)` \|.*/\1/p' "$SKILL_DIR/references/profile-catalog.md" | LC_ALL=C sort)
[[ "$manifest_ids" == "$catalog_ids" ]] || fail 'profile routing catalog must cover all 27 canonical module IDs'

discoverable_count=$(find "$SKILL_DIR" -type f -name SKILL.md | wc -l)
[[ "$discoverable_count" -eq 1 ]] || fail "expected exactly one discoverable SKILL.md in package source, found ${discoverable_count}"

printf 'PASS: public skill package contract\n'
