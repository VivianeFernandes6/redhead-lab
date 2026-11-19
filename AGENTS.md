
# Redhead Lab — Agent Instructions

## Project Overview

Redhead Lab is an iOS application for recording and organizing hair coloring histories, formulas, products, application details, and photos.

The project is developed using Swift and UIKit.

## Technology Stack

- Language: Swift
- UI Framework: UIKit
- Architecture: Feature-Based organization with MVC
- IDE: Xcode
- Platform: iOS
- Backend integration: REST API (planned)

## Architecture and Code Organization

- Follow the existing Feature-Based folder structure.
- Use MVC (Model-View-Controller) within features.
- Keep business models independent from UIKit whenever possible.
- Prefer small, focused, reusable components.
- Avoid unnecessary abstractions and overengineering.
- Respect the existing project structure.

## Development Guidelines

- Use UIKit. Do not introduce SwiftUI.
- Prefer native Apple components and APIs.
- Follow Swift API Design Guidelines.
- Use meaningful names for types, properties, methods, and files.
- Handle optionals and errors explicitly.
- Avoid force unwrapping unless there is a clear justification.
- Keep code readable and maintainable.

## Learning and Collaboration

The project owner is a beginner in iOS development.

- Explain what you are doing and why before making significant changes.
- Prefer step-by-step guidance.
- Explain unfamiliar UIKit and Swift concepts in accessible language.
- Do not overwhelm the owner with unnecessary theoretical explanations.
- Do not replace learning opportunities with unexplained implementations.
- When appropriate, show small examples related to the current task.

## Scope and Decision Making

- Focus on the current MVP.
- Do not implement features outside the agreed scope without asking first.
- Do not introduce new dependencies without approval.
- Do not change the architecture without discussing the reasons.
- Ask questions when requirements are ambiguous.

## Git and Version Control

- Never commit, push, merge, rebase, or create branches without explicit authorization.
- Do not discard or overwrite uncommitted changes.
- Preserve the current Git workflow.
- Suggest conventional commit messages when appropriate.

## Validation

- After relevant code changes, build the project using Xcode or xcodebuild when available.
- Report build errors and warnings accurately.
- Do not claim that code works without validating it.
- Suggest tests when they add meaningful value.
