#!/usr/bin/env bash

set -euo pipefail

script_dir="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(CDPATH='' cd -- "$script_dir/../../.." && pwd)"

required_files=(
  ".specify/memory/constitution.md"
  ".specify/memory/current-system.md"
  ".specify/templates/overrides/spec-template.md"
  ".specify/templates/overrides/plan-template.md"
  ".specify/templates/overrides/tasks-template.md"
  ".specify/extensions.yml"
  "AGENTS.md"
)

failed=0

for relative_path in "${required_files[@]}"; do
  if [[ ! -s "$project_root/$relative_path" ]]; then
    printf 'missing required Spec Kit governance file: %s\n' "$relative_path" >&2
    failed=1
  fi
done

for governed_file in \
  "$project_root/.specify/memory/constitution.md" \
  "$project_root/.specify/memory/current-system.md"; do
  if grep -Eq '\[(PROJECT_NAME|PRINCIPLE_[0-9]+|SECTION_[0-9]+|GOVERNANCE_RULES|CONSTITUTION_VERSION)\]' "$governed_file"; then
    printf 'unresolved governance placeholder in %s\n' "$governed_file" >&2
    failed=1
  fi
done

if [[ -d "$project_root/specs" ]]; then
  while IFS= read -r spec_dir; do
    if [[ ! -s "$spec_dir/spec.md" ]]; then
      printf 'feature directory has no specification: %s\n' "${spec_dir#"$project_root/"}" >&2
      failed=1
    fi
  done < <(find "$project_root/specs" -mindepth 1 -maxdepth 1 -type d -print | sort)
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

printf 'Spec Kit governance validation passed.\n'
