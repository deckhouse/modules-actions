# AGENTS.md

## Debug focus for this repository
- CI issues should be traced through action definitions referenced by `.github/workflows/ci.yml`, especially `build/action.yml`, `lint/action.yml`, `go_tests/action.yaml`, `go_linter/action.yaml`, `go_test_coverage/action.yaml`, `go_modules_check/action.yaml`, `gitleaks/action.yml`, and `cve_scan/action.yml`.
- Mixed `.yml` and `.yaml` filenames are intentional; debug path/filename mismatches before assuming missing files.

## Non-obvious failure points
- Go action failures may occur in per-module loops over `images/**/go.mod`; inspect module-by-module outcomes and aggregated failure handling.
- Edition-specific `GO_BUILD_TAGS` values affect build/test behavior; confirm tag propagation before concluding toolchain regressions.
- There is no repository-level single-test entrypoint; reproductions must follow action-level module loops.
- `build/action.yml` has optional `.att` copy logic; missing attestations can be expected and non-fatal when files are absent.
- `gitleaks/action.yml` applies local config only when `[extend]` exists; otherwise baseline config is expected behavior.
- `cve_scan/action.yml` relies on scripts cloned to `/tmp/cve-scripts`; debug missing-script errors against that clone step/path.

## Rule-file baseline
- No `CLAUDE.md`, `.cursorrules`, `.roorules`, `.cursor/rules`, or `.github/copilot-instructions.md` were found.