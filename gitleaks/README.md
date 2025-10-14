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
- 🛠 `gitleaks.toml` (опционально): конфигурационный файл правил для Gitleaks в корне репозитория. Если отсутствует — используются встроенные правила Gitleaks.

---

## 🚀 Как подключить

### 1. (Опционально) Добавьте конфиг Gitleaks

Если вы хотите использовать собственные правила сканирования, создайте файл `gitleaks.toml` в **корне** вашего репозитория. Пример можно взять из официального репозитория Gitleaks:  
📎 <https://github.com/gitleaks/gitleaks/blob/main/config/gitleaks.toml>

**Если файл отсутствует:** Gitleaks будет использовать встроенные дефолтные правила.

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
          # gitleaks_version: v8.28.0  # опционально, по умолчанию v8.28.0

  gitleaks-full:
    if: ${{ github.event_name != 'pull_request' }}
    runs-on: ubuntu-latest
    continue-on-error: true
    steps:
      - uses: deckhouse/modules-actions/gitleaks@feature/gitleaks
        with:
          scan_mode: full
          # gitleaks_version: v8.28.0  # опционально, по умолчанию v8.28.0
```

---

## 📝 Входные параметры (Inputs)

| Параметр | Описание | Обязательный | Значение по умолчанию |
|----------|----------|--------------|----------------------|
| `scan_mode` | Режим сканирования: `full` или `diff` | Нет | `full` |
| `gitleaks_version` | Версия Gitleaks для установки | Нет | `v8.28.0` |

### Примеры использования

**Использование конкретной версии Gitleaks:**

```yaml
- uses: deckhouse/modules-actions/gitleaks@feature/gitleaks
  with:
    scan_mode: full
    gitleaks_version: v8.20.0
```

**Минимальная конфигурация (используются дефолты):**

```yaml
- uses: deckhouse/modules-actions/gitleaks@feature/gitleaks
