# CVE Scan CI Integration

## Description
This CI runs a Trivy CVE and License scan against module images and their submodule images, then uploads reports to DefectDojo.  
The action clones the [cve-scan](https://github.com/deckhouse/cve-scan) scripts and runs them. The script resolves the registry and tag (release vs dev) from *source_tag* and *case*. If your module uses non-standard paths in registries, set *module_prod_registry_custom_path* and *module_dev_registry_custom_path*.

**CI use cases:**
- **Scheduled** — scan main and several latest releases (e.g. 2–3 times a week)
- **On PR** — scan images for the PR to ensure no new vulnerabilities or that known ones are closed
- **Manual** — scan a specific release (*source_tag* as semver minor, e.g. `1.23`), or main + several latest releases (*scan_several_latest_releases* = true, *latest_releases_amount*), or only main by running the workflow

**BOB inside the action:** The composite action runs `hashicorp/vault-action` first (JWT/OIDC against BOB — our Vault implementation). It exports DefectDojo URL and token, the cve-scan Git URL and SSH key, `DECKHOUSE_PRIVATE_REPO`, and `CODEOWNERS_REPO_TOKEN` for the scan and clone steps. The job must have `permissions: id-token: write` so GitHub can mint the OIDC token for BOB.

## Action reference
Use the reusable action:
```yaml
deckhouse/modules-actions/cve_scan@main
```
(Replace `main` with the branch or tag your repo uses.)

## Inputs

### Optional inputs
| Input | Description |
|-------|-------------|
| `scan_several_latest_releases` | Optional. Scan several latest releases. `true`/`false`. Default: `false` |
| `latest_releases_amount` | Optional. How many latest releases to scan. Default: `3` |
| `release_in_dev` | Optional. If `true`, the release tag is taken from the dev registry. Default: `false` |
| `trivy_reports_log_output` | Optional. Trivy report verbosity in logs: `0` — off, `1` — CVE/FS only, `2` — CVE + License. Default: `1` |
| `module_prod_registry_custom_path` | Custom path for the module in the prod registry. Default: `deckhouse/fe/modules` |
| `module_dev_registry_custom_path` | Custom path for the module in the dev registry. Default: `sys/deckhouse-oss/modules` |
| `workdir` | Working directory for scan artifacts. Default: `cve-scan` |

### Required inputs
| Input | Description |
|-------|-------------|
| `external_module_name` | Required when *case* = "External Modules": the module name whose tag is scanned |
| `source_tag` | Tag to scan: e.g. `main`, `v1.74.3`, `pr123`, `release-1.73` |
| `case` | Scan type: `deckhouse` \| `External Modules` \| `CSE` |
| `prod_registry` | Prod registry host (release images and Trivy DB) |
| `prod_registry_user` | Prod registry username |
| `prod_registry_password` | Prod registry password |
| `dev_registry` | Dev registry host (branch/PR images) |
| `dev_registry_user` | Dev registry username |
| `dev_registry_password` | Dev registry password |
| `role_name` | Optional. Passed to Vault as the JWT role name (repository identifier for auth) |

### Sensitive inputs (mask in logs)
Registry credentials and any secrets you pass explicitly. DefectDojo, CODEOWNERS, Deckhouse private repo URL, and cve-scan SSH material are pulled from BOB inside the action, so you typically do not duplicate them as separate workflow secrets for this action.

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
Use your own Vault or repo secrets for **registry** credentials (and anything else outside the built-in list). DefectDojo, CODEOWNERS, Deckhouse private repo, and cve-scan clone credentials are imported by the action itself; the `dd_*`, `codeowners_*`, `deckhouse_private_repo`, and `cve_*` inputs in the snippet below can remain placeholders if your action version still requires them, or follow your organization’s convention.

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
          prod_registry: ${{ steps.secrets.outputs.PROD_READ_REGISTRY }}
          prod_registry_user: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_USER }}
          prod_registry_password: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_PASSWORD }}
          dev_registry: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_HOST }}
          dev_registry_user: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_USER }}
          dev_registry_password: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_PASSWORD }}
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
          prod_registry: ${{ steps.secrets.outputs.PROD_READ_REGISTRY }}
          prod_registry_user: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_USER }}
          prod_registry_password: ${{ steps.secrets.outputs.PROD_READ_REGISTRY_PASSWORD }}
          dev_registry: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_HOST }}
          dev_registry_user: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_USER }}
          dev_registry_password: ${{ steps.secrets.outputs.DECKHOUSE_DEV_REGISTRY_PASSWORD }}
          latest_releases_amount: ${{ github.event.inputs.latest_releases_amount || '3' }}
          release_in_dev: ${{ github.event.inputs.release_in_dev || 'False' }}
          trivy_reports_log_output: "1"
```

### Example: case: deckhouse
For the main Deckhouse repo, *case* is `deckhouse` and *source_tag* is set from the workflow (e.g. from a previous step like `steps.scan_type.outputs.tag`). Registry credentials must be imported from BOB secrets. The job still needs `id-token: write` because of the built-in Vault step.

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
      scan_several_latest_releases: ${{ steps.scan_type.outputs.scan_several_latest_releases }}
      latest_releases_amount: ${{ steps.scan_type.outputs.latest_releases_amount }}
      trivy_reports_log_output: "2"
```

Full workflow examples: [.examples/cve_scan.yml](../.examples/cve_scan.yml); real usage: [csi-ceph](https://github.com/deckhouse/csi-ceph/blob/main/.github/workflows/trivy_image_check.yaml), [deckhouse cve-pr](https://github.com/deckhouse/deckhouse/blob/main/.github/workflows/cve-pr.yml), [deckhouse cve-weekly](https://github.com/deckhouse/deckhouse/blob/main/.github/workflows/cve-weekly.yml).
