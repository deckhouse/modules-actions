# 🕵️ Gitleaks GitHub Action

## 📌 Что это такое

Этот GitHub Actions workflow автоматически запускает [Gitleaks](https://github.com/gitleaks/gitleaks) — инструмент для поиска секретов в коде (токены, ключи, пароли и т.п.). Он сканирует изменения либо полностью, либо в виде diff-а для Pull Request'ов.

Цель — предотвратить утечку секретов в публичные или приватные репозитории до попадания кода в основную ветку.

---

## ⚙️ Как работает

Workflow состоит из двух режимов:

- **Diff scan** (режим по умолчанию для PR):
  - Запускается при создании или обновлении Pull Request.
  - Сканирует только изменения между текущей веткой и целевой (base) веткой.

- **Full scan**:
  - Запускается по расписанию или вручную.
  - Сканирует весь репозиторий.

Компоненты:
- 📄 `gitleaks.yml`: основной workflow с тремя триггерами — `pull_request`, `schedule`, `workflow_dispatch`.
- ⚙️ `deckhouse/modules-actions/gitleaks@feature/gitleaks`: composite action, устанавливающая и запускающая Gitleaks.
- 🛠 `.github/gitleaks.toml`: обязательный конфигурационный файл правил для Gitleaks (настраивается под ваш проект).

---

## 🚀 Как подключить

### 1. Добавьте конфиг Gitleaks

Создайте файл `.github/gitleaks.toml` в корне вашего репозитория. Пример можно взять из официального репозитория Gitleaks или настроить под себя:  
📎 https://github.com/gitleaks/gitleaks/blob/main/config/gitleaks.toml

### 2. Добавьте workflow-файл

Создайте файл `.github/workflows/gitleaks.yml` со следующим содержимым:

```yaml
name: Gitleaks

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
  schedule:
    - cron: "0 2 * * *"  # ежедневно в 02:00 UTC
  workflow_dispatch: {}  # ручной запуск

permissions:
  contents: read

concurrency:
  group: "gitleaks-${{ github.ref }}"
  cancel-in-progress: false

jobs:
  gitleaks-diff:
    if: ${{ github.event_name == 'pull_request' }}
    runs-on: ubuntu-latest
    steps:
      - uses: deckhouse/modules-actions/gitleaks@feature/gitleaks
        with:
          scan_mode: diff

  gitleaks-full:
    if: ${{ github.event_name != 'pull_request' }}
    runs-on: ubuntu-latest
    continue-on-error: true
    steps:
      - uses: deckhouse/modules-actions/gitleaks@feature/gitleaks
        with:
          scan_mode: full
