# Retry Action

**⚠️ INTERNAL USE ONLY** - This action is designed for use within this repository only and should not be called externally.

A reusable composite GitHub Action that executes a command with retry logic.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `command` | Command to execute | Yes | - |
| `description` | Description of the operation for logging | Yes | - |
| `max_retries` | Maximum number of retries (0 = no retries, 1 = 1 retry, etc.) | No | `0` |
| `retry_delay` | Delay in seconds between retry attempts | No | `5` |

## Usage

```yaml
- name: Copy image with retries
  uses: ./retry
  with:
    command: crane copy source:tag destination:tag
    description: copy container image
    max_retries: 3
    retry_delay: 5
```

## Example

```yaml
- name: Push Docker image with retries
  uses: ./retry
  with:
    command: docker push myregistry.com/myimage:latest
    description: push Docker image
    max_retries: ${{ inputs.push_retry_attempts }}
```
