# AGENTS.md

## Code-mode repository specifics
- Action definitions intentionally use mixed filenames: keep existing `.yml`/`.yaml` names unchanged (`build/action.yml`, `go_tests/action.yaml`, etc.).
- CI composes behavior from action files referenced by `.github/workflows/ci.yml`; make edits in action files rather than assuming centralized scripts.

## Implementation patterns to preserve
- Go-related actions operate by iterating `images/**/go.mod` modules; preserve per-module loop structure and failure aggregation behavior.
- Keep `GO_BUILD_TAGS` edition-tag plumbing intact across build/test flows.
- `build/action.yml` must continue optional `.att` attestation copy behavior when files are present.
- `gitleaks/action.yml` should only apply local config when `[extend]` exists; otherwise keep baseline config pathing.
- `cve_scan/action.yml` depends on helper scripts cloned to `/tmp/cve-scripts`; do not inline/relocate this dependency.

## Test-command surface
- No single-module/single-test command is exposed by repository actions; tests are executed via action-level module loops.