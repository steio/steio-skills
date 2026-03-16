# GitHub Actions CI/CD Best Practices

## Security

### Pin Action Versions

Always pin actions to a specific version or SHA:

```yaml
# Good
- uses: actions/checkout@v4
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # SHA

# Bad
- uses: actions/checkout@main  # Unstable
```

### Minimal Permissions

Set minimal permissions at workflow and job level:

```yaml
permissions:
  contents: read      # Read repository contents
  pull-requests: write  # Comment on PRs (if needed)
  id-token: write     # OIDC token (for cloud auth)
```

### Secrets Management

- Never log secrets
- Use `add-mask` for dynamic secrets
- Use repository or organization secrets
- Consider OIDC over static credentials

## Performance

### Dependency Caching

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'  # Automatic caching
```

### Matrix Strategy

Run tests across multiple versions:

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
    os: [ubuntu-latest, macos-latest]
  fail-fast: false
```

### Conditional Execution

```yaml
jobs:
  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

## Reliability

### Timeouts

```yaml
jobs:
  test:
    timeout-minutes: 30
```

### Continue on Error

For non-critical steps:

```yaml
- name: Notify
  continue-on-error: true
  run: ./notify.sh
```

### Concurrency

Cancel redundant runs:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Common Patterns

### Lint → Test → Build → Deploy

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps: [...]

  test:
    needs: lint
    strategy:
      matrix: [...]
    steps: [...]

  build:
    needs: test
    steps: [...]

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    steps: [...]
```

### Environment Variables

```yaml
env:
  NODE_ENV: test
  CI: true

jobs:
  test:
    env:
      DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}
```

### Reusable Workflows

Create reusable workflows:

```yaml
# .github/workflows/test.yml
on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
```

Use them:

```yaml
jobs:
  test:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '20'
```

## Error Handling

### Job Failure Handling

```yaml
jobs:
  notify:
    runs-on: ubuntu-latest
    if: failure()
    needs: [test, build]
    steps:
      - name: Notify on failure
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -d '{"text": "CI failed for ${{ github.repository }}"}'
```

## Status Badges

```markdown
![CI](https://github.com/owner/repo/actions/workflows/ci.yml/badge.svg)
```