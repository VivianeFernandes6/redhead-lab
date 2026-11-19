
---
name: swift-uikit
description: Use when implementing, modifying, debugging, or explaining Swift and UIKit code in the Redhead Lab iOS application.
---

# Swift and UIKit Development

## Project Context

Redhead Lab is an iOS application developed with Swift and UIKit.

The project uses Feature-Based organization with MVC.

## Swift Guidelines

- Follow Swift API Design Guidelines.
- Prefer clear and descriptive names.
- Use optionals safely.
- Avoid force unwrapping without justification.
- Prefer value types when appropriate.
- Keep functions focused and readable.
- Handle errors explicitly.

## UIKit Guidelines

- Use UIKit for all application interfaces.
- Prefer native Apple components.
- Use Auto Layout for programmatic layouts.
- Respect safe areas.
- Follow Apple's Human Interface Guidelines.
- Separate view configuration from business logic.
- Avoid putting business logic inside UIViewController.

## View Controllers

- Keep UIViewController responsibilities focused.
- Extract reusable views when appropriate.
- Use clear lifecycle methods.
- Avoid unnecessarily large view controllers.

## Project Conventions

- Follow the existing folder structure.
- Reuse existing models and components.
- Do not introduce SwiftUI.
- Do not add dependencies without approval.
- Avoid unnecessary abstractions.

## Learning Approach

The project owner is a beginner in iOS development.

When implementing code:
1. Explain the purpose of the change.
2. Describe the relevant UIKit concepts briefly.
3. Prefer incremental implementation.
4. Explain important decisions.
5. Avoid unrelated theoretical explanations.
