# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Repository-specific execution map
- CI behavior is composed through action definitions in `build/action.yml`, `deploy/action.yml`, `lint/action.yml`, `go_tests/action.yaml`, `go_linter/action.yaml`, `go_test_coverage/action.yaml`, `go_modules_check/action.yaml`, `gitleaks/action.yml`, and `cve_scan/action.yml`, orchestrated by `.github/workflows/ci.yml`.
- Keep existing filename conventions: both `.yml` and `.yaml` are intentionally used across actions.

## Non-obvious behavior to preserve
- Go checks iterate all `images/**/go.mod` entries and run per-module loops; avoid assumptions of a single module root.
- Go build/test flows use `GO_BUILD_TAGS` edition tags; changes must preserve edition-driven tag handling.
- No dedicated single-test entrypoint is exposed in this repo’s action surface (tests are wired via action-level module loops).
- `build/action.yml` copies `.att` attestations when present; do not remove optional attestation copy logic.
- `gitleaks/action.yml` honors a local config only when it contains `[extend]`; otherwise baseline behavior is used.
- `cve_scan/action.yml` clones external helper scripts into `/tmp/cve-scripts`; this external dependency path is expected.

## Agent-rule file baseline
- No pre-existing agent/rule instruction files were found (`CLAUDE.md`, `.cursorrules`, `.roorules`, `.cursor/rules`, `.github/copilot-instructions.md`).