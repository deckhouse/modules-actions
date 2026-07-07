# Installed Tools Inventory

This file lists tools that are **explicitly installed** by repository actions, deduplicated across all actions.

| Tool | Version | Action file(s) | Installation method |
|---|---|---|---|
| werf | dynamic/latest (tool version not pinned); installer action pinned: `werf/actions/install@v2` | [`setup/action.yml`](setup/action.yml) | Installed via `werf/actions/install@v2` without explicit werf version input. |
| crane | dynamic/latest (not pinned); installer action pinned: `imjasonh/setup-crane@v0.4` | [`setup/action.yml`](setup/action.yml) | Installed via `imjasonh/setup-crane@v0.4` without explicit crane version input. |
| gh (GitHub CLI) | `v2.94.0` default (overridable via input `tool_version`) | [`gh/action.yml`](gh/action.yml) | Installed from GitHub Releases archive `gh_<version>_<arch>.tar.gz`; action input default is `v2.94.0`. |
| Go toolchain | `1.25` default (overridable via input `go_version`) | [`go_tests/action.yaml`](go_tests/action.yaml), [`go_test_coverage/action.yaml`](go_test_coverage/action.yaml), [`go_modules_check/action.yaml`](go_modules_check/action.yaml), [`go_linter/action.yaml`](go_linter/action.yaml) | Installed via `actions/setup-go@v5` with `go-version: ${{ inputs.go_version }}` (default `1.25`). |
| golangci-lint | `v2.9.0` (pinned) | [`go_linter/action.yaml`](go_linter/action.yaml) | Installed with `go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.9.0`. |
| Python | `3.11` default (overridable via input `python_version`) | [`translate-changelog/action.yml`](translate-changelog/action.yml) | Installed via `actions/setup-python@v5` with `python-version: ${{ inputs.python_version }}` (default `3.11`). |
| Python packages (`pyyaml`, `deep-translator`, `packaging`) | not pinned (dynamic/latest from PyPI) | [`translate-changelog/action.yml`](translate-changelog/action.yml) | Installed with `pip install pyyaml deep-translator packaging` (no version constraints). |
| dmt | dynamic by channel (`stable`), exact app version not pinned | [`lint/action.yml`](lint/action.yml) | Installed via `werf/trdl/actions/setup-app@main` using `repo: dmt`, `channel: stable`, `root-version: 3`. |
| gitleaks | `v8.28.0` default (overridable via input `gitleaks_version`) | [`gitleaks/action.yml`](gitleaks/action.yml) | Installed by downloading `gitleaks_${TOOL_VERSION#v}_<arch>.tar.gz` from GitHub Releases; action input default is `v8.28.0`. |
