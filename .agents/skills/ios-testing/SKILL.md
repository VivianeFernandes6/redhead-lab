
---
name: ios-testing
description: Use when creating, reviewing, running, or debugging unit tests and UI tests for the Redhead Lab iOS application.
---

# iOS Testing — Redhead Lab

## Project Context

- Redhead Lab is developed using Swift and UIKit.
- The project follows Feature-Based organization with MVC.
- Use XCTest for testing.
- The project owner is a beginner in iOS development.

## Testing Strategy

Prioritize tests for:

- Domain models.
- Data validation.
- Business rules.
- Data transformations.
- Important user interactions.
- Critical application flows.

## Unit Tests

- Use XCTest.
- Prefer small, independent tests.
- Use descriptive test names.
- Follow Arrange, Act, Assert when appropriate.
- Test expected behavior and edge cases.
- Avoid unnecessary dependencies on external services.

## UI Tests

- Use XCUITest when validating actual user interactions is valuable.
- Focus on critical user journeys.
- Prefer accessibility identifiers for reliable element selection.
- Avoid fragile tests dependent on visual coordinates.

## Mock Data

- Reuse mock data when appropriate.
- Keep test data predictable.
- Avoid relying on changing values such as Date() when deterministic values are required.
- Do not use production services for isolated tests.

## Test Quality

- Tests should validate behavior, not implementation details.
- Avoid redundant tests.
- Make failures easy to understand.
- Do not modify production code solely to satisfy a poorly designed test.

## Learning Guidelines

- Explain what each important test validates.
- Explain why the scenario matters.
- Introduce testing concepts gradually.
- Avoid overwhelming the project owner with advanced theory.

## Restrictions

- Do not introduce testing dependencies without approval.
- Do not expand the MVP without approval.
- Do not commit, push, merge, or change branches.
- Do not discard or overwrite existing user changes.
