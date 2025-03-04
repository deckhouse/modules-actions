# CVE Scan CI Integration

## Description
This CI file will run a Trivy CVE scan against the module images and its submodule images, and then upload the reports to DefectDojo.

## Variables

### Job level
```
IMAGE - URL to a registry image, e.g., registry.example.com/deckhouse/modules/module_name
TAG - module image tag
MODULE_NAME - module name
```

### GitLab Masked variables
```
DD_URL - URL to defectDojo
DD_TOKEN - token of defectDojo to upload reports
TRIVY_REGISTRY - must be deckhouse prod registry, used to get trivy databases
TRIVY_REGISTRY_USER - username to log in to deckhouse prod registry
TRIVY_REGISTRY_PASSWORD - password to log in to deckhouse prod registry
TRIVY_TOKEN - token of private repo to get trivy from
DECKHOUSE_PRIVATE_REPO - url to private repo
```

## How to include

Put the following step of job into required place of you GitHub Action file (usually after build step/job if exist):  
```
      - uses: deckhouse/modules-actions/cve_scan@cve_scan_ci
        with:
          IMAGE: registry.example.com/path/to/module
          TAG: module_image_tag
          MODULE_NAME: module_name
          DD_URL: ${{secrets.DEFECTDOJO_HOST}}
          DD_TOKEN: ${{secrets.DEFECTDOJO_API_TOKEN}}
          TRIVY_REGISTRY: ${{ vars.PROD_REGISTRY }}
          TRIVY_REGISTRY_USER: ${{ vars.PROD_MODULES_REGISTRY_LOGIN }}
          TRIVY_REGISTRY_PASSWORD: ${{ secrets.PROD_MODULES_REGISTRY_PASSWORD }}
          TRIVY_TOKEN: ${{secrets.FOX_ACCESS_TOKEN}}
          DECKHOUSE_PRIVATE_REPO: ${{secrets.DECKHOUSE_PRIVATE_REPO}}
```

Usage example can be found [here](../.examples/cve_scan.yml)
