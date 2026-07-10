# Migrate from black + isort to ruff

> **Why:** ruff replaces black (formatting), isort (import sorting), and flake8 (linting) with a single tool. It's 10-100x faster and catches ~120 additional violations. The `.github` CI templates assume ruff.

## Steps

### 1. Remove old tools

```bash
pip uninstall black isort flake8 -y
# or remove from requirements-dev.txt / pyproject.toml
```

### 2. Install ruff

```bash
pip install ruff
# or add to requirements-dev.txt
```

### 3. Replace pre-commit hooks

In `.pre-commit-config.yaml`, replace:

```yaml
# OLD — remove these
- repo: https://github.com/psf/black
  rev: ...
  hooks:
    - id: black
- repo: https://github.com/pycqa/isort
  rev: ...
  hooks:
    - id: isort
```

With the template from `templates/pre-commit/python-pre-commit.yaml`:

```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.12.0  # run `pre-commit autoupdate` after copying
  hooks:
    - id: ruff
      args: [--fix]
    - id: ruff-format
```

### 4. Configure ruff

Add to `pyproject.toml`:

```toml
[tool.ruff]
target-version = "py312"
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP", "B", "SIM", "C4"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

### 5. Run auto-fix

```bash
ruff check --fix .   # fix auto-fixable violations
ruff format .         # format code
```

### 6. Fix remaining violations manually

```bash
ruff check .   # review and fix each remaining error
```

### 7. Verify pre-commit passes

```bash
pre-commit run --all-files
```

## Common issues

| Symptom | Fix |
|---------|-----|
| `SIM108` (use ternary operator) | Ruff auto-fixes this |
| `B007` (unused loop variable) | Replace with `_` |
| `UP006` (use `list` not `List`) | Ruff auto-fixes this |
| Line length violations | Set `line-length` in `[tool.ruff]` to match your old config |
| Import ordering changes | Ruff's `I` rules handle this; run `ruff check --fix .` |
