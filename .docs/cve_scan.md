# CVE Scan CI Integration

## Description
This CI file will run a Trivy CVE scan against the module images and its submodule images, and then upload the reports to DefectDojo.

## Variables

### Job level
```
image - URL to a registry image, e.g., registry.example.com/deckhouse/modules/module_name
tag - module image tag
module_name - module name
```

### GitHub Masked variables
```
dd_url - URL to defectDojo
dd_token - token of defectDojo to upload reports
trivy_registry - must be deckhouse prod registry, used to get trivy databases
trivy_registry_user - username to log in to deckhouse prod registry
trivy_registry_password - password to log in to deckhouse prod registry
deckhouse_private_repo - url to private repo
```

## How to include

Put the following step of job into required place of you GitHub Action file (usually after build step/job if exist):  
```
      - uses: deckhouse/modules-actions/cve_scan@cve_scan_ci
        with:
          image: registry.example.com/path/to/module
          tag: module_image_tag
          module_name: module_name
          dd_url: ${{secrets.DEFECTDOJO_HOST}}
          dd_token: ${{secrets.DEFECTDOJO_API_TOKEN}}
          trivy_registry: ${{ vars.PROD_REGISTRY }}
          trivy_registry_user: ${{ vars.PROD_MODULES_REGISTRY_LOGIN }}
          trivy_registry_password: ${{ secrets.PROD_MODULES_REGISTRY_PASSWORD }}
          deckhouse_private_repo: ${{secrets.DECKHOUSE_PRIVATE_REPO}}
```

Usage example can be found [here](../.examples/cve_scan.yml)
