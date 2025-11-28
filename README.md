<p align="center">
  <img alt="Deckhouse Kubernetes Platform" src=".docs/images/logos/DH_sign_dark_mode.svg#gh-dark-mode-only" alt="Deckhouse Kubernetes Platform" />
  <img alt="Deckhouse Kubernetes Platform" src=".docs/images/logos/DH_sign_light_mode.svg#gh-light-mode-only" alt="Deckhouse Kubernetes Platform" />
</p>

# Deckhouse Modules Actions

## Overview

This repository contains GitHub Actions workflows for building and deploying modules for the Deckhouse Kubernetes Platform.

## Workflows
| Workflow                              | Description                                                                                                           |
|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| [**setup**](./setup/action.yml)       | Sets up the environment for building and deploying modules. This workflow **must** be run before any other workflows. |
| [**build**](./build/action.yml)       | Builds the Deckhouse modules using the [werf](https://werf.io/) tool.                                                 |
| [**deploy**](./deploy/action.yml)     | Deploys the Deckhouse modules to the one of selected release channels.                                                |
| [**cve_scan**](./cve_scan/action.yml) | Trivy CVE Scan of module images. Documentation can be found [here](./.docs/cve_scan.md)                               |
| [**svace_analyze**](./svace_analyze/action.yml) | Include svace analyze action to analyze and import builds made with svace tool  |

## Examples

All examples are located in the [examples](./.examples) directory. They show how to use the workflows in different scenarios.

1. `build.yaml` — can be run for each PR commit and when a new release is created. Builds the modules and pushes them to the container registry.
2. `deploy.yaml` — can be run after releasing a new version of the modules. Deploys the modules to the selected release channel.
3. `cve_scan.yaml` — can run for each PR commit, manually and by push to main branch. Scans modules images for CVE and uploads reports to DefectDojo
4. `svace_analyze.yaml` — can be run after successfully build with svace tool. Analyze builds with svace analyze tool and imports to the Svacer.

## Usage

To use these GitHub Action workflows in your own repository:

1. Copy the workflows (YAML files) from the `.examples` directory into your repository.

2. Adjust the workflow files based on your specific requirements and configurations.

3. Make sure to configure any necessary secrets or environment variables in your GitHub repository settings to enable secure deployment.

4. Trigger the workflows manually or automatically on each push, pull request, or any other event as needed.
