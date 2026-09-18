#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: decision-handoff.sh --decision <decision> --target <dir> --lang <id|en> \
  --module <module_id> --initializer <command> --validator <command> [OPTIONS]

Apply an approved adoption decision without resolving commands from the caller's cwd.

Required options:
  --decision <decision>              CANCEL, DEFER, PRESERVE, SKIP, or APPROVE_REPLACE_WITH_BACKUP.
  --target <dir>                     Existing target directory selected by the user.
  --lang <id|en>                     Language selected in the completed preview.
  --module <module_id>               Exact module ID selected in the completed preview.
  --preview-fingerprint <sha256>     Fingerprint emitted by the completed preview.
  --initializer <command>            Executable canonical initializer command.
  --validator <command>              Executable canonical validator command.

Approval options (repeat once per exact existing conflict path):
  --conflict <path=decision>         Exact path and APPROVE_* decision from the preview.
  --backup-mapping <path=backup>     Exact old-path to backup-path mapping.
  --rollback-mapping <path=command>  Exact old-path to rollback command mapping.
  --gitignore-decision <YES|NO>      Explicit decision for the approved backup directory.

Legacy single-path aliases are accepted only as AGENTS.md mappings:
  --backup-path <path>               Alias for --backup-mapping AGENTS.md=<path>.
  --rollback-command <command>       Alias for --rollback-mapping AGENTS.md=<command>.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 2
}

DECISION=''
TARGET=''
LANG_VAL=''
MODULE_ID=''
PREVIEW_FINGERPRINT=''
INITIALIZER=''
VALIDATOR=''
GITIGNORE_DECISION=''
declare -a CONFLICT_ENTRIES=()
declare -a BACKUP_ENTRIES=()
declare -a ROLLBACK_ENTRIES=()

while (($# > 0)); do
  case "$1" in
    --decision)
      (($# >= 2)) || fail '--decision requires a value'
      DECISION="$2"
      shift 2
      ;;
    --target)
      (($# >= 2)) || fail '--target requires a directory path'
      TARGET="$2"
      shift 2
      ;;
    --lang)
      (($# >= 2)) || fail '--lang requires id or en'
      LANG_VAL="$2"
      shift 2
      ;;
    --module)
      (($# >= 2)) || fail '--module requires a module ID'
      MODULE_ID="$2"
      shift 2
      ;;
    --preview-fingerprint)
      (($# >= 2)) || fail '--preview-fingerprint requires a SHA-256 value'
      PREVIEW_FINGERPRINT="$2"
      shift 2
      ;;
    --initializer)
      (($# >= 2)) || fail '--initializer requires an executable command'
      INITIALIZER="$2"
      shift 2
      ;;
    --validator)
      (($# >= 2)) || fail '--validator requires an executable command'
      VALIDATOR="$2"
      shift 2
      ;;
    --conflict)
      (($# >= 2)) || fail '--conflict requires path=decision'
      CONFLICT_ENTRIES+=("$2")
      shift 2
      ;;
    --backup-mapping)
      (($# >= 2)) || fail '--backup-mapping requires path=backup'
      BACKUP_ENTRIES+=("$2")
      shift 2
      ;;
    --rollback-mapping)
      (($# >= 2)) || fail '--rollback-mapping requires path=command'
      ROLLBACK_ENTRIES+=("$2")
      shift 2
      ;;
    --backup-path)
      (($# >= 2)) || fail '--backup-path requires a path'
      BACKUP_ENTRIES+=("AGENTS.md=$2")
      shift 2
      ;;
    --rollback-command)
      (($# >= 2)) || fail '--rollback-command requires a command'
      ROLLBACK_ENTRIES+=("AGENTS.md=$2")
      shift 2
      ;;
    --gitignore-decision)
      (($# >= 2)) || fail '--gitignore-decision requires YES or NO'
      GITIGNORE_DECISION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown option: $1"
      ;;
  esac
done

[[ -n "$DECISION" ]] || fail '--decision is required'
[[ -n "$TARGET" ]] || fail '--target is required'
[[ -d "$TARGET" ]] || fail "target directory does not exist: $TARGET"
[[ "$LANG_VAL" == id || "$LANG_VAL" == en ]] || fail '--lang must be id or en'
[[ "$MODULE_ID" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail '--module must be a canonical module ID'
[[ -n "$INITIALIZER" ]] || fail '--initializer is required'
[[ -x "$INITIALIZER" ]] || fail "initializer command is not executable: $INITIALIZER"
[[ -n "$VALIDATOR" ]] || fail '--validator is required'
[[ -x "$VALIDATOR" ]] || fail "validator command is not executable: $VALIDATOR"

# The canonical initializer leaves project placeholders intact unless a name is
# supplied. Derive a deterministic name from the explicitly selected target so
# the subsequent instantiated validation checks the generated project, not a
# still-raw template. Replacement approvals also require --force to apply only
# after the handoff has completed its backup gate.
TARGET_NAME="$(basename -- "$(cd -- "$TARGET" && pwd -P)")"

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

path_snapshot() {
  local path="$1" file relative
  if [[ -f "$path" && ! -d "$path" ]]; then
    printf 'file %s\n' "$(hash_file "$path")"
    return
  fi
  printf 'directory\n'
  while IFS= read -r file; do
    relative="${file#"${path}/"}"
    printf '%s %s\n' "$relative" "$(hash_file "$file")"
  done < <(find "$path" -type f -print | LC_ALL=C sort)
}

calculate_preview_fingerprint() {
  local governance_path
  {
    printf 'target=%s\nlang=%s\nmodule=%s\n' "$(cd -- "$TARGET" && pwd -P)" "$LANG_VAL" "$MODULE_ID"
    for governance_path in AGENTS.md README.md backlog.md mission.md governance.md docs/; do
      if [[ -e "$TARGET/${governance_path}" ]]; then
        printf 'path=%s\n' "$governance_path"
        path_snapshot "$TARGET/${governance_path%/}"
      else
        printf 'path=%s absent\n' "$governance_path"
      fi
    done
  } | if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

deferred() {
  printf 'State: DEFERRED\nMutation: none\nTarget: unchanged\n'
  exit 0
}

case "$DECISION" in
  CANCEL)
    printf 'State: CANCELLED\nMutation: none\nTarget: unchanged\n'
    exit 0
    ;;
  DEFER|PRESERVE|APPROVE_PRESERVE|SKIP|APPROVE_SKIP|MERGE|APPROVE_MERGE)
    deferred
    ;;
  APPROVE_REPLACE_WITH_BACKUP) ;;
  *) fail "unsupported decision: $DECISION" ;;
esac

declare -A actual_conflicts=() approved_decisions=() backup_map=() rollback_map=() source_snapshot=()
declare -A backup_destinations=()
declare -a actual_paths=()
if [[ -e "$TARGET/AGENTS.md" || -L "$TARGET/AGENTS.md" ]]; then
  actual_conflicts['AGENTS.md']=1
  actual_paths+=(AGENTS.md)
fi
if [[ -d "$TARGET/docs" ]]; then
  actual_conflicts['docs/']=1
  actual_paths+=(docs/)
fi

for entry in "${CONFLICT_ENTRIES[@]}"; do
  [[ "$entry" == *=* ]] || fail '--conflict requires path=decision'
  path="${entry%%=*}"
  decision="${entry#*=}"
  [[ "$path" == AGENTS.md || "$path" == README.md || "$path" == backlog.md || "$path" == mission.md || "$path" == governance.md || "$path" == docs/ ]] ||
    fail 'conflict decision set must exactly match target conflicts'
  [[ -z "${approved_decisions[$path]+present}" ]] || fail 'duplicate conflict decision'
  case "$decision" in
    APPROVE_PRESERVE|APPROVE_MERGE|APPROVE_REPLACE_WITH_BACKUP|APPROVE_SKIP) ;;
    *) fail 'conflict decision set must use normalized APPROVE_* decisions' ;;
  esac
  approved_decisions["$path"]="$decision"
done

if ((${#approved_decisions[@]} != ${#actual_paths[@]})); then
  fail 'conflict decision set must exactly match target conflicts'
fi
for path in "${actual_paths[@]}"; do
  [[ -n "${approved_decisions[$path]+present}" ]] ||
    fail 'conflict decision set must exactly match target conflicts'
done
for path in "${!approved_decisions[@]}"; do
  [[ -n "${actual_conflicts[$path]+present}" ]] ||
    fail 'conflict decision set must exactly match target conflicts'
done

is_safe_relative_path() {
  local path="$1"
  [[ -n "$path" && "$path" != /* && "$path" != '..' && "$path" != ../* &&
    "$path" != */../* && "$path" != */.. && "$path" != *'//'* ]]
}

for entry in "${BACKUP_ENTRIES[@]}"; do
  [[ "$entry" == *=* ]] || fail '--backup-mapping requires path=backup'
  path="${entry%%=*}"
  backup="${entry#*=}"
  [[ "$path" == AGENTS.md || "$path" == README.md || "$path" == backlog.md || "$path" == mission.md || "$path" == governance.md || "$path" == docs/ ]] ||
    fail 'backup mapping must use an approved conflict path'
  [[ -z "${backup_map[$path]+present}" ]] || fail 'duplicate backup mapping'
  is_safe_relative_path "$backup" || fail 'backup mapping must remain within target'
  backup_key="${backup%/}"
  [[ -z "${backup_destinations[$backup_key]+present}" ]] || fail 'backup mappings must use unique destinations'
  backup_destinations["$backup_key"]="$path"
  backup_map["$path"]="$backup"
done
for entry in "${ROLLBACK_ENTRIES[@]}"; do
  [[ "$entry" == *=* ]] || fail '--rollback-mapping requires path=command'
  path="${entry%%=*}"
  command_text="${entry#*=}"
  [[ "$path" == AGENTS.md || "$path" == README.md || "$path" == backlog.md || "$path" == mission.md || "$path" == governance.md || "$path" == docs/ ]] ||
    fail 'rollback mapping must use an approved conflict path'
  [[ -n "$command_text" && "$command_text" != not_applicable ]] ||
    fail 'replacement requires a rollback mapping for every approved path'
  [[ -z "${rollback_map[$path]+present}" ]] || fail 'duplicate rollback mapping'
  rollback_map["$path"]="$command_text"
done

snapshot_path() {
  local path="$1" file relative
  if [[ -f "$path" && ! -d "$path" ]]; then
    printf 'file\n'
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$path" | awk '{print $1}'
    else
      shasum -a 256 "$path" | awk '{print $1}'
    fi
    return
  fi
  [[ -d "$path" ]] || return 1
  printf 'directory\n'
  while IFS= read -r file; do
    relative="${file#"$path/"}"
    printf '%s ' "$relative"
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$file" | awk '{print $1}'
    else
      shasum -a 256 "$file" | awk '{print $1}'
    fi
  done < <(find "$path" -type f -print | LC_ALL=C sort)
}

for path in "${actual_paths[@]}"; do
  [[ "${approved_decisions[$path]}" == APPROVE_REPLACE_WITH_BACKUP ]] || deferred
done

[[ "$PREVIEW_FINGERPRINT" =~ ^[0-9a-fA-F]{64}$ ]] || fail '--preview-fingerprint must be a SHA-256 value'
calculated_fingerprint="$(calculate_preview_fingerprint)"
[[ "$PREVIEW_FINGERPRINT" == "$calculated_fingerprint" ]] ||
  fail 'preview fingerprint does not match the current target preview'

if ((${#actual_paths[@]} == 0)); then
  ((${#BACKUP_ENTRIES[@]} == 0 && ${#ROLLBACK_ENTRIES[@]} == 0)) ||
    fail 'backup mappings are not allowed without an approved replacement path'
else
  [[ "$GITIGNORE_DECISION" == YES || "$GITIGNORE_DECISION" == NO ]] ||
    fail 'replacement requires an explicit gitignore decision: YES or NO'
  ((${#backup_map[@]} == ${#actual_paths[@]} && ${#rollback_map[@]} == ${#actual_paths[@]})) ||
    fail 'replacement requires exact backup and rollback mappings for every conflict'
  for path in "${actual_paths[@]}"; do
    [[ -n "${backup_map[$path]+present}" && -n "${rollback_map[$path]+present}" ]] ||
      fail 'replacement requires exact backup and rollback mappings for every conflict'
    source_path="$TARGET/${path%/}"
    backup_path="$TARGET/${backup_map[$path]%/}"
    [[ "$source_path" != "$backup_path" ]] || fail 'backup mapping must differ from approved source path'
    [[ -e "$source_path" || -L "$source_path" ]] || fail "approved source path is missing: $path"
    for other_path in "${actual_paths[@]}"; do
      other_source_path="$TARGET/${other_path%/}"
      [[ "$backup_path" != "$other_source_path/"* ]] ||
        fail 'backup mapping must not be inside an approved source path'
    done
    source_snapshot["$path"]="$(snapshot_path "$source_path")" || fail "could not inventory approved path: $path"
  done

  for path in "${actual_paths[@]}"; do
    backup_path="$TARGET/${backup_map[$path]%/}"
    if [[ -e "$backup_path" || -L "$backup_path" ]]; then
      [[ "$(snapshot_path "$backup_path")" == "${source_snapshot[$path]}" ]] ||
        fail "existing backup does not match approved source path: $path"
    else
      backup_parent=$(dirname -- "$backup_path")
      [[ ! -e "$backup_parent" || -d "$backup_parent" ]] ||
        fail "backup parent is not a directory: $backup_parent"
    fi
  done

  backup_phase=true
  created_backups=()
  created_backup_parents=()
  cleanup_failed_backup_phase() {
    local status=$? path parent
    if [[ "$backup_phase" == true && "$status" != 0 ]]; then
      for path in "${created_backups[@]}"; do
        rm -rf -- "$path" || true
      done
      for parent in "${created_backup_parents[@]}"; do
        rmdir -- "$parent" 2>/dev/null || true
      done
    fi
    return "$status"
  }
  trap cleanup_failed_backup_phase EXIT

  for path in "${actual_paths[@]}"; do
    source_path="$TARGET/${path%/}"
    backup_path="$TARGET/${backup_map[$path]%/}"
    if [[ -e "$backup_path" || -L "$backup_path" ]]; then
      continue
    else
      backup_parent=$(dirname -- "$backup_path")
      missing_parent="$backup_parent"
      while [[ "$missing_parent" != "$TARGET" && ! -e "$missing_parent" ]]; do
        created_backup_parents+=("$missing_parent")
        missing_parent=$(dirname -- "$missing_parent")
      done
      mkdir -p -- "$(dirname -- "$backup_path")"
      created_backups+=("$backup_path")
      if [[ -d "$source_path" ]]; then
        cp -R -- "$source_path" "$backup_path"
      else
        cp -- "$source_path" "$backup_path"
      fi
    fi
  done

  for path in "${actual_paths[@]}"; do
    source_path="$TARGET/${path%/}"
    backup_path="$TARGET/${backup_map[$path]%/}"
    [[ "$(snapshot_path "$source_path")" == "${source_snapshot[$path]}" ]] ||
      fail "approved source changed while creating backup: $path"
    [[ "$(snapshot_path "$backup_path")" == "${source_snapshot[$path]}" ]] ||
      fail "backup verification failed for approved path: $path"
  done
  backup_phase=false
fi

"$INITIALIZER" --lang "$LANG_VAL" --module "$MODULE_ID" --target "$TARGET" --force --name "$TARGET_NAME"
"$VALIDATOR" --target "$TARGET" --mode instantiated
printf 'State: BOOTSTRAP_APPROVED\nMutation: delegated\nTarget: %s\n' "$TARGET"
for path in "${actual_paths[@]}"; do
  printf 'BACKUP_MAPPING=%s -> %s\n' "$path" "${backup_map[$path]}"
  printf 'ROLLBACK_MAPPING=%s -> %s\n' "$path" "${rollback_map[$path]}"
done
if ((${#actual_paths[@]} == 0)); then
  printf 'GITIGNORE_DECISION=not_applicable\n'
else
  printf 'GITIGNORE_DECISION=%s\n' "$GITIGNORE_DECISION"
fi
