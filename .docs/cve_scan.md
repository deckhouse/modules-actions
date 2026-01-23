# CVE Scan CI Integration

## Description
This CI file will run a Trivy CVE scan against the module images and its submodule images, and then upload the reports to DefectDojo.  
The script will detect release or dev tag of module image is used and then construct registry location by itself. If your module located in registries by not standart paths - you may want to define custom path by *module_prod_registry_custom_path* and *module_dev_registry_custom_path* variables.  
CI Use cases:  
- Scan by scheduler
  - Scan main branch and several latest releases 2-3 times a week
- Scan on PR
  - Scan images on pull request to check if no new vulnerabilities are present or to ensure if they are closed.
- Manual scan
  - Scan specified release by entering semver minor version of target release in *release_branch* variable.
  - Scan main branch and several latest releases by setting *scan_several_lastest_releases* to "true" and optionally defining amount of latest minor releases by setting a number into *latest_releases_amount* variable.
  - Scan only main branch just by running pipeline

## Variables

### workflow_dispatch level
```
release_branch - Optional. Set minor version of release you want to scan. e.g.: 1.23
scan_several_lastest_releases - Optional. Whether to scan last several releases or not. true/false. For scheduled pipelines it is always true. Default is: false.
latest_releases_amount - Optional. Number of latest releases to scan. Default is: 3
severity - Optional. Vulnerabilities severity to scan. Default is: UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL
TRIVY_REPORTS_LOG_OUTPUT - 0 - no output, 1 - only CVE, 2 - CVE & License. Output Trivy reports into CI job log, default - 2
```

### Job level

#### Mandatory
```
tag - module image tag
module_name - module name
dd_url - URL to defectDojo
dd_token - token of defectDojo to upload reports
deckhouse_private_repo - url to private repo
prod_registry - Must be deckhouse prod registry, used to get trivy databases and release images
prod_registry_user - Username to log in to deckhouse prod registry
prod_registry_password - Password to log in to deckhouse prod registry
dev_registry - Must be deckhouse dev registry, used to get dev images
dev_registry_user - Username to log in to deckhouse dev registry
dev_registry_password - Password to log in to deckhouse dev registry
```
#### Optional
```
scan_several_lastest_releases - true/false. Whether to scan last several releases or not. For scheduled pipelines override will not work as value is always true
latest_releases_amount - Number of latest minor releases to scan. Latest patch versions of latest N minor versions will be taken. Default is: 3
severity - Vulnerabilities severity to scan. Default is: UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL
module_prod_registry_custom_path - Module custom path in prod registry. Example: flant/modules
module_dev_registry_custom_path - Module custom path in dev registry. Example: flant/modules
```

### GitHub Masked variables
```
dd_url - URL to defectDojo
dd_token - token of defectDojo to upload reports
deckhouse_private_repo - url to private repo
prod_registry - Must be deckhouse prod registry, used to get trivy databases and release images
prod_registry_user - Username to log in to deckhouse prod registry
prod_registry_password - Password to log in to deckhouse prod registry
dev_registry - Must be deckhouse dev registry, used to get dev images
dev_registry_user - Username to log in to deckhouse dev registry
dev_registry_password - Password to log in to deckhouse dev registry
```

## How to include

Set trigger rules with scheduler, manual and pull requests in your cve scan CI file:  
```
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
        description: 'Optional. Set minor version of release you want to scan. e.g.: 1.23'
        required: false
      scan_several_lastest_releases:
        description: 'Optional. Whether to scan last several releases or not. true/false. For scheduled pipelines it is always true. Default is: false.'
        required: false
      latest_releases_amount:
        description: 'Optional. Number of latest releases to scan. Default is: 3'
        required: false
      severity:
        description: 'Optional. Vulnerabilities severity to scan. Default is: UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL'
        required: false
```

Put the following jobs into required place of you GitHub Action file (usually after build step/job if exist):  
```
  cve_scan_on_pr:
    if: github.event_name == 'pull_request'
    name: CVE scan for PR
    needs: [build_dev]
    steps:
      - uses: actions/checkout@v4
      - uses: deckhouse/modules-actions/cve_scan@v3
        with:
          tag: pr${{ github.event.number }}
          module_name: ${{ vars.MODULE_NAME }}
          dd_url: ${{ secrets.DEFECTDOJO_HOST }}
          dd_token: ${{ secrets.DEFECTDOJO_API_TOKEN }}
          prod_registry: ${{ secrets.PROD_READ_REGISTRY }}
          prod_registry_user: ${{ secrets.PROD_MODULES_READ_REGISTRY_USER }}
          prod_registry_password: ${{ secrets.PROD_MODULES_READ_REGISTRY_PASSWORD }}
          dev_registry: ${{ secrets.DEV_REGISTRY }}
          dev_registry_user: ${{ secrets.DEV_MODULES_REGISTRY_USER }}
          dev_registry_password: ${{ secrets.DEV_MODULES_REGISTRY_PASSWORD }}
          deckhouse_private_repo: ${{ secrets.DECKHOUSE_PRIVATE_REPO }}
  cve_scan:
    if: github.event_name != 'pull_request'
    name: Regular CVE scan
    steps:
      - uses: actions/checkout@v4
      - uses: deckhouse/modules-actions/cve_scan@v3
        with:
          tag: ${{ github.event.inputs.release_branch || github.event.repository.default_branch }}
          module_name: ${{ vars.MODULE_NAME }}
          dd_url: ${{ secrets.DEFECTDOJO_HOST }}
          dd_token: ${{ secrets.DEFECTDOJO_API_TOKEN }}
          prod_registry: ${{ secrets.PROD_READ_REGISTRY }}
          prod_registry_user: ${{ secrets.PROD_MODULES_READ_REGISTRY_USER }}
          prod_registry_password: ${{ secrets.PROD_MODULES_READ_REGISTRY_PASSWORD }}
          dev_registry: ${{ secrets.DEV_REGISTRY }}
          dev_registry_user: ${{ secrets.DEV_MODULES_REGISTRY_USER }}
          dev_registry_password: ${{ secrets.DEV_MODULES_REGISTRY_PASSWORD }}
          deckhouse_private_repo: ${{ secrets.DECKHOUSE_PRIVATE_REPO }}
          scan_several_lastest_releases: ${{ github.event.inputs.scan_several_lastest_releases }}
          latest_releases_amount: ${{ github.event.inputs.latest_releases_amount || '3' }}
          severity: ${{ github.event.inputs.severity }}
```

Usage example can be found [here](../.examples/cve_scan.yml)

