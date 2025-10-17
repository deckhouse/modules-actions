# 🕵️ Gitleaks GitHub Action

## 📌 Purpose

GitHub Action for automatic secret scanning in code using [Gitleaks](https://github.com/gitleaks/gitleaks). Prevents leakage of tokens, keys, passwords, and other secrets into the repository.

## ⚙️ Operation Modes

### Diff scan (primary mode)
- **Automatically integrated** into general PR validation
- Scans **only changed files** and **only added lines** in PR
- Does not analyze commit history — eliminates false positives
- Does not check unchanged files — focuses on new code
- Uses `--no-git` for fast scanning

### Full scan (additional mode)
- Runs on schedule or manually
- Scans the entire repository
- Suitable for periodic security audits

## 🚀 Usage

### Automatic Integration

Diff scan is already integrated into general PR validation and works automatically. No additional configuration required.

### Full Scanning (optional)

If you need full scan, add to `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan

on:
  schedule:
    - cron: "0 2 * * *"  # daily at 02:00 UTC
  workflow_dispatch: {}  # manual trigger

permissions:
  contents: read

jobs:
  gitleaks-full:
    runs-on: ubuntu-latest
    steps:
      - uses: deckhouse/modules-actions/gitleaks@main
        with:
          scan_mode: full
```

### Configuration (optional)

To configure scanning rules, create `gitleaks.toml` in the repository root:
📎 <https://github.com/gitleaks/gitleaks/blob/main/config/gitleaks.toml>

Without config, built-in Gitleaks rules are used.

## 📝 Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `scan_mode` | Mode: `diff` or `full` | `full` |
| `gitleaks_version` | Gitleaks version | `v8.28.0` |
| `checkout_repo` | Repository for checkout | `${{ github.repository }}` |
| `checkout_ref` | SHA for checkout | `""` |
| `base_sha` | Base SHA for diff | `""` |

## 🔧 Technical Features

### Patch-based scanning (diff mode)
- Collects only changed files from PR
- Creates temporary tree with these files
- Scans without git history (`--no-git`)
- Filters findings only by added lines

### Benefits
- **Minimal false positives** — doesn't find deleted secrets
- **Fast operation** — scans only changes
- **Accuracy** — focuses on new code in PR

## 🐛 Troubleshooting

**Many false positives**: use `diff` mode for PR checks
**Workflow fails**: check `contents: read` permissions
**Need configuration**: create `gitleaks.toml` in repository root
