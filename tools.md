# Installed Tools Inventory

This file lists tools that are **explicitly installed** by repository actions, deduplicated across all actions.

| Tool | Action file(s) | Installation method |
|---|---|---|
| werf | [`setup/action.yml`](setup/action.yml), [`lint/action.yml`](lint/action.yml) | Installed in [`setup/action.yml`](setup/action.yml) via `werf/actions/install@v1.2.1`; also used in [`lint/action.yml`](lint/action.yml) as the backend for `werf/trdl/actions/setup-app@v2`. |
| crane | [`setup/action.yml`](setup/action.yml) | Installed via `imjasonh/setup-crane@v0.4`. |
| gh (GitHub CLI) | [`gh/action.yml`](gh/action.yml) | Installed from apt packages (`gh`) after adding the GitHub CLI apt repository and keyring. |
| Go toolchain | [`go_tests/action.yaml`](go_tests/action.yaml), [`go_test_coverage/action.yaml`](go_test_coverage/action.yaml), [`go_modules_check/action.yaml`](go_modules_check/action.yaml), [`go_linter/action.yaml`](go_linter/action.yaml) | Installed via `actions/setup-go@v5` (version from action input). |
| golangci-lint | [`go_linter/action.yaml`](go_linter/action.yaml) | Installed with `go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest`. |
| Python | [`translate-changelog/action.yml`](translate-changelog/action.yml) | Installed via `actions/setup-python@v4` (`python-version: "3.11"`). |
| Python packages (`pyyaml`, `deep-translator`, `packaging`) | [`translate-changelog/action.yml`](translate-changelog/action.yml) | Installed with `pip install pyyaml deep-translator packaging`. |
| dmt | [`lint/action.yml`](lint/action.yml) | Installed via `werf/trdl/actions/setup-app@v2` (`repo: dmt`, fixed `version`). |
| gitleaks | [`gitleaks/action.yml`](gitleaks/action.yml) | Installed by downloading and extracting the upstream release archive (`gitleaks_${VERSION}_linux_x64.tar.gz`) from GitHub Releases. |
