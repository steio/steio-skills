# Handle Ambiguous Request

Skill asks clarifying questions instead of generating prematurely.

## Setup

- New session, no context

## Task

User: "create a skill"

## Expected Behavior

- Does NOT generate files
- Asks clarifying question
- Waits for response

## Validation

1. No files created on first message
2. Question asked about domain/purpose
3. Waits for user response