# AGENTS.md

## Architecture constraints discovered in this repository
- CI architecture is composition of action files referenced by `.github/workflows/ci.yml` rather than a single central script.
- Preserve intentional mixed action filename convention (`.yml` and `.yaml`) across directories.

## Design-level behaviors to preserve in plans
- Go quality gates are module-scoped loops over `images/**/go.mod`; architecture changes should retain per-module execution and failure aggregation semantics.
- Edition-driven `GO_BUILD_TAGS` handling is part of build/test design and should remain first-class in any redesign.
- Repository action surface does not provide a single-test entrypoint; test strategy proposals must align with loop-based action execution.
- `build/action.yml` includes optional `.att` artifact copy behavior when attestations exist.
- `gitleaks/action.yml` applies local config conditionally on `[extend]` presence.
- `cve_scan/action.yml` depends on helper scripts cloned into `/tmp/cve-scripts`.

## Rule-file baseline
- No `CLAUDE.md`, `.cursorrules`, `.roorules`, `.cursor/rules`, or `.github/copilot-instructions.md` are present.