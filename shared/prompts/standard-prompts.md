# Shared Prompts

## Code Generation Prompts

### API Endpoint
```
Create a REST API endpoint for [resource] with:
- HTTP method: [GET/POST/PUT/DELETE]
- Authentication: [none/jwt/api-key]
- Validation: [fields to validate]
- Error handling: [error types]
```

### Database Schema
```
Design a database schema for [entity] with:
- Fields: [list fields]
- Relations: [relations to other entities]
- Indexes: [indexes needed]
- Constraints: [constraints]
```

### Test Suite
```
Generate tests for [functionality]:
- Type: [unit/integration/e2e]
- Framework: [jest/pytest/etc]
- Coverage: [what to cover]
- Edge cases: [edge cases to test]
```

## Review Prompts

### Code Review
```
Review this code for:
- Security vulnerabilities
- Performance issues
- Code style consistency
- Error handling
- Test coverage
```

### Architecture Review
```
Analyze this architecture for:
- Scalability concerns
- Security boundaries
- Coupling analysis
- Failure modes
```

## Debugging Prompts

### Error Analysis
```
Analyze this error:
- Stack trace: [paste]
- Context: [what was happening]
- Expected: [what should happen]

Provide:
1. Root cause analysis
2. Fix suggestions
3. Prevention strategies
```