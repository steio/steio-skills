# Security Checklist

## Authentication & Authorization

- [ ] Authentication mechanisms are secure
- [ ] Authorization checks are implemented
- [ ] Session management is secure
- [ ] Password policies enforced

## Input Validation

- [ ] All user input is validated
- [ ] Input is sanitized before use
- [ ] Type checking is implemented
- [ ] Length limits enforced

## Data Protection

- [ ] Sensitive data is encrypted at rest
- [ ] Data in transit uses TLS
- [ ] No sensitive data in logs
- [ ] Proper data retention policies

## Injection Prevention

- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevented (output encoding)
- [ ] Command injection prevented
- [ ] Path traversal prevented

## Secrets Management

- [ ] No hardcoded secrets
- [ ] Secrets stored securely
- [ ] Secrets rotated regularly
- [ ] Minimal secret access

## Dependencies

- [ ] Dependencies are up to date
- [ ] No known vulnerabilities
- [ ] Minimal dependency footprint
- [ ] Dependencies from trusted sources

## Infrastructure

- [ ] Security headers configured
- [ ] HTTPS enforced
- [ ] Proper firewall rules
- [ ] Logging and monitoring enabled

## Compliance

- [ ] GDPR requirements met
- [ ] PCI-DSS if applicable
- [ ] SOC 2 if applicable
- [ ] Industry-specific regulations followed