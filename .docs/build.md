# Build action

## Description

The **build** composite action builds a Deckhouse module with [werf](https://werf.io/), pushes bundle and release-channel images to the registry, registers the module tag, and optionally copies VEX attestations for the bundle image.

Run **setup** before **build** in the same job.

```yaml
deckhouse/modules-actions/build@main
```

## New in `vex-attestations`

### Edition and build report artifact

Pass `edition` when building edition-specific modules (e.g. `fe`, `ee`). The action:

1. Exports `EDITION` for werf.
2. Uploads `images_tags_werf.json` as a workflow artifact named `build_report_<edition>` (or `build_report` when edition is empty).

The artifact is saved even when the build step fails, so downstream jobs can inspect image metadata.

### Vault and registry authentication

Optional inputs are forwarded to the werf build environment:

| Input | Env var | Description |
|-------|---------|-------------|
| `vault_addr` | `VAULT_ADDR` | Vault server address |
| `vault_key` | `VAULT_KEY` | Key name in Vault |
| `vault_role` | `VAULT_ROLE` | Vault auth role |
| `transit_secret_engine_path` | `TRANSIT_SECRET_ENGINE_PATH` | Transit secrets engine path |
| `registry_user` | `REGISTRY_USER` | Registry username - is used for cosign attestations |
| `registry_password` | `REGISTRY_PASSWORD` | Registry password - is used for cosign attestations |

### Bundle VEX attestation

After `crane copy` pushes the bundle image, the action checks for an attestation tag:

```
<repo>:sha256-<digest>.att
```

If the manifest exists, it is copied to the same tag on the destination repo. If not, the step logs a skip message and continues.

## Inputs

### Required

| Input | Description |
|-------|-------------|
| `module_source` | Registry repository for the module, e.g. `registry.example.com/module-source` |
| `module_name` | Module name, e.g. `my-module` |
| `module_tag` | Version tag, e.g. `v1.21.1` or branch name |

### Optional

| Input | Description |
|-------|-------------|
| `secondary_repo` | Secondary registry path for the module |
| `source_repo` | Source Git repository URL |
| `source_repo_ssh_key` | SSH key for `source_repo` |
| `svace_enabled` | Enable Svace static analysis integration |
| `svace_analyze_host` | Svace analyze server hostname |
| `svace_analyze_ssh_user` | SSH user for Svace server |
| `svace_analyze_ssh_key` | SSH private key for Svace server |
| `edition` | Module edition; sets `EDITION` and artifact name suffix |
| `vault_addr` | Vault address for signing/secrets |
| `vault_key` | Vault key name |
| `vault_role` | Vault JWT/OIDC role |
| `transit_secret_engine_path` | Vault transit engine path |
| `registry_user` | Registry username for werf build |
| `registry_password` | Registry password for werf build |

## Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: deckhouse/modules-actions/setup@v4
        with:
          registry: registry.deckhouse.io
          registry_login: ${{ secrets.REGISTRY_LOGIN }}
          registry_password: ${{ secrets.REGISTRY_PASSWORD }}
      - uses: deckhouse/modules-actions/build@main
        with:
          module_source: registry.deckhouse.io/deckhouse/fe/modules
          module_name: my-module
          module_tag: ${{ github.ref_name }}
          edition: fe
          vault_addr: ${{ secrets.VAULT_ADDR }}
          vault_key: ${{ secrets.VAULT_KEY }}
          vault_role: ${{ secrets.VAULT_ROLE }}
          transit_secret_engine_path: ${{ secrets.TRANSIT_SECRET_ENGINE_PATH }}
          registry_user: ${{ secrets.REGISTRY_USER }}
          registry_password: ${{ secrets.REGISTRY_PASSWORD }}
```

## Artifacts

| Artifact name | Contents | When |
|---------------|----------|------|
| `build_report` | `images_tags_werf.json` | Build finished (success or failure), no `edition` |
| `build_report_<edition>` | `images_tags_werf.json` | Build finished (success or failure), `edition` set |

Full workflow example: [.examples/build.yml](../.examples/build.yml).

PR changelog for this feature set: [CHANGELOG-vex-attestations.md](./CHANGELOG-vex-attestations.md).
