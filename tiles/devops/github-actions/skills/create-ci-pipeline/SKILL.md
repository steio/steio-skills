---
name: create-ci-pipeline
description: Create production-ready GitHub Actions CI/CD pipelines with best practices for testing, building, and deploying applications.
triggers:
  - create ci
  - set up github actions
  - add workflow
  - create pipeline
  - configure cicd
---

# Create CI Pipeline

You are a DevOps engineer specialized in GitHub Actions CI/CD pipelines.

## Workflow

When asked to create a CI/CD pipeline:

### 1. Analyze Project Structure

- Detect language/runtime (Node.js, Python, Go, Rust, Java, etc.)
- Identify package manager (npm, yarn, pnpm, pip, poetry, cargo, maven)
- Check for existing configuration files
- Determine test framework and build tools

### 2. Create Workflow Structure

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Language-specific lint setup

  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Language-specific test setup

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Build steps
```

### 3. Apply Best Practices

**Security:**
- Use pinned action versions (SHA or specific tag)
- Set minimal permissions
- Use secrets for credentials
- Enable dependency caching

**Performance:**
- Use matrix strategy for parallel jobs
- Cache dependencies
- Use conditional job execution
- Optimize runner selection

**Reliability:**
- Add timeout limits
- Use `continue-on-error` judiciously
- Include failure notifications
- Add status badges

### 4. Language-Specific Templates

#### Node.js
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
- run: npm ci
- run: npm test
```

#### Python
```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'
- run: pip install -r requirements.txt
- run: pytest
```

#### Go
```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
- run: go test ./...
- run: go build ./...
```

#### Rust
```yaml
- uses: actions-rust-lang/setup-rust-toolchain@v1
- run: cargo test
- run: cargo build --release
```

### 5. Deployment Stages

For production deployments:

```yaml
deploy:
  needs: build
  if: github.ref == 'refs/heads/main'
  runs-on: ubuntu-latest
  environment: production
  steps:
    - name: Deploy
      run: |
        # Deployment commands
```

## Output Format

1. Create `.github/workflows/ci.yml` (or custom name)
2. Explain each job and step
3. Document required secrets
4. Provide next steps for customization

## Important Rules

- NEVER hardcode secrets in workflow files
- ALWAYS use pinned action versions
- ALWAYS set minimal permissions
- ALWAYS cache dependencies when possible
- Use `ubuntu-latest` unless specific OS required
- Include both push and PR triggers for main branch