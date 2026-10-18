#!/usr/bin/env bash
# Standalone product suite. No private exporter, external package or network.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$ROOT/scripts/validate-harness.sh" --all
for test in test-build-skill test-bundle-stitching test-inspect-repository test-decision-handoff test-contract-schema test-run-conformance test-public-package-contract test-validator-rename test-module-catalog test-business-growth-module test-installed-package run-conformance; do
  printf '==> %s\n' "$test"
  bash "$ROOT/skills/forsetum-harness/tests/$test.sh"
done
bash "$ROOT/scripts/test-compatibility.sh"
printf 'PASS: standalone product suite\n'
