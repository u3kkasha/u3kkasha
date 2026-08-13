# Synchronize Current-System Memory

Reconcile a completed feature's verified implementation into
`.specify/memory/current-system.md`.

## Inputs

Use `$ARGUMENTS` to select a feature directory when supplied. Otherwise resolve the
active feature from `.specify/feature.json` or
`.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks`.

## Procedure

1. Read `.specify/memory/constitution.md`, `.specify/memory/current-system.md`, and the
   feature's `spec.md`, `plan.md`, and `tasks.md`.
2. Inspect the implemented source and verification evidence. Do not infer operational
   status solely from an unchecked task or planned design.
3. Compare delivered reality with every claim identified under `Current-System Impact`
   and `Current-System Reconciliation`.
4. Update only affected current claims:
   - capability status and supported path;
   - implemented architecture and module boundaries;
   - security, state, trust, caching, or ownership policy;
   - maintenance and verification commands; and
   - known limitations that were proven resolved, introduced, or materially changed.
5. Keep future work in feature artifacts. Never describe planned behavior as operational,
   never rewrite historical feature rationale, and never copy an entire plan into memory.
6. If no claim changed, leave the memory file byte-for-byte unchanged and report the
   evidence-based reason.
7. Mark the corresponding memory-sync task complete in `tasks.md` when present, then run
   `.specify/scripts/bash/validate-project.sh`.

## Completion Report

Report which current-system sections changed, which implementation evidence supports
them, and whether any planned or uncertain claim was deliberately excluded.
