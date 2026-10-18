#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/forsetum-business-growth-test.XXXXXX")"
PUBLIC_DIR="${TMP_ROOT}/installed skill"
trap 'rm -rf -- "${TMP_ROOT}"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

for lang in en id; do
  manifest="${ROOT_DIR}/template/${lang}/manifest.json"
  grep -Fq '"business-growth": {' "${manifest}" \
    || fail "${lang} manifest does not declare business-growth"
  docs=(
    01-strategy/positioning-and-market-focus.md
    02-offer-and-operations/service-model-and-delivery.md
    03-growth-engine/acquisition-and-conversion.md
    04-sustainability-and-metrics/recurring-revenue-retention-and-kpis.md
  )
  bundle_dir="${TMP_ROOT}/${lang}"
  bash "${ROOT_DIR}/scripts/bundle.sh" --lang "${lang}" --module business-growth \
    --name "Business Growth Fixture" --dir "${bundle_dir}" >/dev/null \
    || fail "${lang} bundle failed"
  for doc in "${docs[@]}"; do
    [[ -s "${bundle_dir}/docs/${doc}" ]] || fail "${lang} bundle omitted ${doc}"
    grep -Fq "(${doc})" "${bundle_dir}/docs/INDEX.md" \
      || fail "${lang} bundle index omitted ${doc}"
  done
done

public_dir="${PUBLIC_DIR}"
bash "${ROOT_DIR}/scripts/build-skill.sh" --output "$public_dir" >/dev/null \
  || fail 'native package build failed'

for lang in en id; do
  [[ -d "${public_dir}/runtime/template/${lang}/modules/business-growth" ]] \
    || fail "business-growth missing from approved public ${lang} modules"
  diff -r "${ROOT_DIR}/template/${lang}/modules/business-growth" \
    "${public_dir}/runtime/template/${lang}/modules/business-growth" >/dev/null \
    || fail "public ${lang} business-growth differs from canonical source"
  diff -r "${public_dir}/runtime/template/${lang}/modules/business-growth" \
    "${ROOT_DIR}/skills/forsetum-harness/runtime/template/${lang}/modules/business-growth" >/dev/null \
    || fail "public ${lang} business-growth runtime differs from exported template"
done

printf 'PASS: business-growth is symmetric, bundleable, and included in the public package/runtime\n'
