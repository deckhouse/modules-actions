# CVE Scan CI Integration

## Description
This CI runs a Trivy CVE and License scan against module images and their submodule images, then uploads reports to DefectDojo.  
The action clones the [cve-scan](https://github.com/deckhouse/cve-scan) scripts and runs them. The script resolves the registry and tag (release vs dev) from *source_tag* and *case*. If your module uses non-standard paths in registries, set *module_prod_registry_custom_path* and *module_dev_registry_custom_path*.

**CI use cases:**
- **Scheduled** — scan main and several latest releases (e.g. 2–3 times a week)
- **On PR** — scan images for the PR to ensure no new vulnerabilities or that known ones are closed
- **Manual** — scan a specific release (*source_tag* as semver minor, e.g. `1.23`), or main + several latest releases (*scan_several_latest_releases* = true, *latest_releases_amount*), or only main by running the workflow

## Action reference
Use the reusable action:
```yaml
deckhouse/modules-actions/cve_scan@main
```
(Replace `main` with the branch or tag your repo uses.)

## Inputs

### workflow_dispatch (optional inputs)
| Input | Description |
|-------|-------------|
| `release_branch` / source_tag | Optional. Minor version to scan, e.g. `1.23`, or leave empty for default branch |
| `scan_several_latest_releases` | Optional. Scan several latest releases. `true`/`false`. For scheduled runs it is always true. Default: `false` |
| `latest_releases_amount` | Optional. Number of latest releases to scan. Default: `3` |
| `release_in_dev` | Optional. If `true`, release tag is taken from dev registry. Default: `false` |
| `trivy_reports_log_output` | Optional. Trivy report verbosity in logs: `0` — off, `1` — CVE/FS only, `2` — CVE + License. Default: `1` |
| `external_module_name` | Optional. For *case* = "External Modules": the module name whose tag is scanned |

### Job level — mandatory (action inputs)
| Input | Description |
|-------|-------------|
| `source_tag` | Tag to scan: e.g. `main`, `v1.74.3`, `pr123`, `release-1.73` |
| `case` | Scan type: `deckhouse` \| `External Modules` \| `CSE` |
| `dd_url` | DefectDojo API URL |
| `dd_token` | DefectDojo API token |
| `prod_registry` | Prod registry host (e.g. for release images and Trivy DB) |
| `prod_registry_user` | Prod registry username |
| `prod_registry_password` | Prod registry password |
| `dev_registry` | Dev registry host (e.g. for branch/PR images) |
| `dev_registry_user` | Dev registry username |
| `dev_registry_password` | Dev registry password |
| `codeowners_repo_token` | Token for CODEOWNERS configmap |
| `deckhouse_private_repo` | Deckhouse private repo URL (e.g. GitLab for Trivy binary and configmap) |
| `cve_test_repo_git` | cve-scan repo clone URL (SSH) |
| `cve_ssh_private_key` | SSH key for cloning cve-scan repo |

### Job level — optional
| Input | Description |
|-------|-------------|
| `external_module_name` | Required when *case* = "External Modules". Module name in registry path |
| `scan_several_latest_releases` | `True`/`False`. For scheduled runs this is typically overridden to true |
| `latest_releases_amount` | Number of latest minor releases to scan. Default: `3` |
| `release_in_dev` | If true, look for release tag in dev registry. Default: `False` |
| `trivy_reports_log_output` | `0` \| `1` \| `2`. Default: `1` |
| `module_prod_registry_custom_path` | Custom path for module in prod registry. Default: `deckhouse/fe/modules` |
| `module_dev_registry_custom_path` | Custom path for module in dev registry. Default: `sys/deckhouse-oss/modules` |
| `workdir` | Working directory for scan artifacts. Default: `cve-scan` |

### Sensitive inputs (mask in logs)
`dd_url`, `dd_token`, `deckhouse_private_repo`, registry credentials, `codeowners_repo_token`, `cve_ssh_private_key`.

## How to include

### Triggers
```yaml
on:
  schedule:
    - cron: '0 01 * * 0,3'
  pull_request:
    types: [opened, reopened, labeled, synchronize]
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      release_branch:
        description: 'Optional. Minor version to scan. e.g.: 1.23'
        required: false
      scan_several_latest_releases:
        description: 'Optional. Scan several latest releases. true/false. Default: false.'
        required: false
      latest_releases_amount:
        description: 'Optional. Number of latest releases to scan. Default: 3'
        required: false
      release_in_dev:
        description: 'If true, release tag is taken from dev registry. Default: false'
        required: false
      trivy_reports_log_output:
        description: 'Optional. 0=off, 1=CVE only, 2=CVE+License. Default: 1'
        required: false
      external_module_name:
        description: 'For External Modules: module name to scan'
        required: false
```

### Example: External Modules (e.g. csi-ceph)
Secrets are often provided via BOB (`hashicorp/vault-action`); use `steps.secrets.outputs.*` for registry and DefectDojo credentials.

```yaml
  cve_scan_on_pr:
    if: github.event_name == 'pull_request'
    name: CVE scan for PR
    runs-on: [self-hosted, regular]
    needs: [build_dev]
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
      # Optional: split repo name, import secrets from BOB
      - uses: deckhouse/modules-actions/cve_scan@main
        with:
          source_tag: 'pr${{ github.event.number }}'
          case: "External Modules"
          external_module_name: ${{ vars.MODULE_NAME }}
          dd_url: ${{ steps.secrets.outputs.DEFECTDOJO_URL }}
          dd_token: ${{ steps.secrets.outputs.DEFECTDOJO_API_TOKEN }}
          prod_registry: ${{ steps.secrets.outputs.PROD_READ_REGISTRY }}
          prod_registry_user: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_USER }}
          prod_registry_password: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_PASSWORD }}
          dev_registry: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_HOST }}
          dev_registry_user: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_USER }}
          dev_registry_password: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_PASSWORD }}
          deckhouse_private_repo: ${{ steps.secrets.outputs.DECKHOUSE_PRIVATE_REPO }}
          codeowners_repo_token: ${{ steps.secrets.outputs.CODEOWNERS_REPO_TOKEN }}
          cve_test_repo_git: ${{ steps.secrets.outputs.CVE_TEST_REPO_GIT }}
          cve_ssh_private_key: ${{ steps.secrets.outputs.CVE_TEST_SSH_PRIVATE_KEY }}
          trivy_reports_log_output: "1"

  cve_scan:
    if: github.event_name != 'pull_request'
    name: Regular CVE scan
    runs-on: [self-hosted, regular]
    needs: [build_dev]
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
      # Optional: import secrets from BOB
      - uses: deckhouse/modules-actions/cve_scan@main
        with:
          source_tag: ${{ github.event.inputs.release_branch || github.event.repository.default_branch }}
          case: "External Modules"
          external_module_name: ${{ vars.MODULE_NAME }}
          dd_url: ${{ steps.secrets.outputs.DEFECTDOJO_URL }}
          dd_token: ${{ steps.secrets.outputs.DEFECTDOJO_API_TOKEN }}
          prod_registry: ${{ steps.secrets.outputs.PROD_READ_REGISTRY }}
          prod_registry_user: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_USER }}
          prod_registry_password: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_PASSWORD }}
          dev_registry: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_HOST }}
          dev_registry_user: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_USER }}
          dev_registry_password: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_PASSWORD }}
          deckhouse_private_repo: ${{ steps.secrets.outputs.DECKHOUSE_PRIVATE_REPO }}
          scan_several_latest_releases: ${{ github.event.inputs.scan_several_latest_releases || 'True' }}
          latest_releases_amount: ${{ github.event.inputs.latest_releases_amount || '3' }}
          release_in_dev: ${{ github.event.inputs.release_in_dev || 'False' }}
          codeowners_repo_token: ${{ steps.secrets.outputs.CODEOWNERS_REPO_TOKEN }}
          cve_test_repo_git: ${{ steps.secrets.outputs.CVE_TEST_REPO_GIT }}
          cve_ssh_private_key: ${{ steps.secrets.outputs.CVE_TEST_SSH_PRIVATE_KEY }}
          trivy_reports_log_output: "1"
```

### Example: Deckhouse core (case: deckhouse)
For the main Deckhouse repo, *case* is `deckhouse` and *source_tag* is set from workflow (e.g. from a previous step like `steps.scan_type.outputs.tag`). Prod registry credentials may come from repo secrets or BOB.

```yaml
  - uses: deckhouse/modules-actions/cve_scan@main
    with:
      source_tag: ${{ steps.scan_type.outputs.tag }}
      case: "deckhouse"
      prod_registry: ${{ secrets.DECKHOUSE_REGISTRY_READ_HOST }}
      prod_registry_user: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_USER }}
      prod_registry_password: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_PASSWORD }}
      dev_registry: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_HOST }}
      dev_registry_user: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_USER }}
      dev_registry_password: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_PASSWORD }}
      codeowners_repo_token: ${{ steps.secrets.outputs.CODEOWNERS_REPO_TOKEN }}
      deckhouse_private_repo: ${{ steps.secrets.outputs.DECKHOUSE_PRIVATE_REPO }}
      dd_url: ${{ steps.secrets.outputs.DD_URL }}
      dd_token: ${{ steps.secrets.outputs.DD_TOKEN }}
      cve_test_repo_git: ${{ steps.secrets.outputs.CVE_TEST_REPO_GIT }}
      cve_ssh_private_key: ${{ steps.secrets.outputs.CVE_SSH_PRIVATE_KEY }}
      scan_several_latest_releases: ${{ steps.scan_type.outputs.scan_several_latest_releases }}
      latest_releases_amount: ${{ steps.scan_type.outputs.latest_releases_amount }}
      trivy_reports_log_output: "2"
```

Full workflow examples: [.examples/cve_scan.yml](../.examples/cve_scan.yml); real usage: [csi-ceph](https://github.com/deckhouse/csi-ceph/blob/main/.github/workflows/trivy_image_check.yaml), [deckhouse cve-pr](https://github.com/deckhouse/deckhouse/blob/main/.github/workflows/cve-pr.yml), [deckhouse cve-weekly](https://github.com/deckhouse/deckhouse/blob/main/.github/workflows/cve-weekly.yml).
