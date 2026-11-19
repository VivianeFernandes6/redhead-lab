
---
name: ios-architecture
description: Use when designing features, organizing files, defining responsibilities, or making architectural decisions in the Redhead Lab iOS project.
---

# iOS Architecture — Redhead Lab

## Architectural Approach

Redhead Lab uses:

- Feature-Based folder organization.
- MVC (Model-View-Controller) as its architectural pattern.
- Swift as its programming language.
- UIKit for its user interface.

Feature-Based and MVC are complementary:
- Feature-Based organizes the project by application functionality.
- MVC separates data, interface, and presentation responsibilities.

## Project Structure

The current project structure follows this organization:

- App: application lifecycle and configuration.
- Core/Models: shared domain models.
- Core/Networking: API communication.
- Core/Extensions: reusable extensions.
- Core/Utilities: shared utilities.
- Core/Mock: mock data for development.
- Features: application features organized independently.
- Resources: assets and visual resources.

## MVC Responsibilities

### Model
- Represents application data and domain concepts.
- Contains domain rules when appropriate.
- Should remain independent from UIKit whenever possible.
- Must not depend on view controllers.

### View
- Displays information to the user.
- Handles visual configuration and layout.
- Should not contain business logic.
- Should communicate user interactions through appropriate mechanisms.

### Controller
- Coordinates interactions between Model and View.
- Handles view lifecycle and presentation logic.
- Should not become responsible for every application concern.
- Should remain focused and maintainable.

## Feature Organization

Each feature should group its related files.

Example:

Features/
  Gallery/
    Controllers/
    Models/
    Views/

Features/
  ColoringForm/
    Controllers/
    Models/
    Views/

Avoid moving shared domain models into individual features without a clear reason.

## Architectural Decisions

- Prefer simple solutions that fit the current MVP.
- Avoid unnecessary abstractions.
- Avoid duplicated models and responsibilities.
- Reuse shared components when appropriate.
- Do not introduce new architectural patterns without approval.
- Discuss significant structural changes before implementing them.

## Learning Guidelines

The project owner is a beginner in iOS development.

When proposing architectural changes:
1. Explain the problem being solved.
2. Explain why the proposed structure is appropriate.
3. Identify which files need to change.
4. Avoid unnecessary architectural terminology.
5. Prefer incremental changes.
