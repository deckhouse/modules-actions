# AGENTS.md

## Repository-specific facts to prioritize in answers
- CI logic is action-driven via `.github/workflows/ci.yml` and action files such as `build/action.yml`, `lint/action.yml`, `go_tests/action.yaml`, `go_linter/action.yaml`, `go_test_coverage/action.yaml`, `go_modules_check/action.yaml`, `gitleaks/action.yml`, and `cve_scan/action.yml`.
- Mixed `.yml`/`.yaml` filenames are intentional in this repository.

## Non-obvious behaviors worth calling out
- Go validation/test actions run per module by iterating `images/**/go.mod`, with aggregated failure behavior across modules.
- `GO_BUILD_TAGS` edition tags are part of Go build/test control flow.
- No single-module/single-test command is exposed at repository action level.
- `build/action.yml` includes optional `.att` attestation copy behavior when files exist.
- `gitleaks/action.yml` uses local config only when `[extend]` is present.
- `cve_scan/action.yml` expects helper scripts cloned to `/tmp/cve-scripts`.

## Rule-file baseline
- No `CLAUDE.md`, `.cursorrules`, `.roorules`, `.cursor/rules`, or `.github/copilot-instructions.md` are present.