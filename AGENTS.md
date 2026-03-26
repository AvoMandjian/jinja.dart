# AGENTS.md - Jinja.dart Project

## Project Overview
Jinja2 template engine port for Dart 3. Provides server-side template rendering capabilities.

## Code Style and Conventions

### Dart Linting Rules
- Follows standard Dart/Flutter lints
- Prefer single quotes (`prefer_single_quotes: true`)
- Require trailing commas (`require_trailing_commas: true`)
- Avoid print statements (`avoid_print: true`)
- Do not require `always_use_package_imports`
- Prefer relative imports (`prefer_relative_imports: true`)
- Lines longer than 80 chars are allowed (lint disabled)

### Code Patterns
- Template engine pattern (Jinja2 port)
- Loader abstraction for template sources
- Environment-based configuration
- Debug support with breakpoints
  - `onBreakpoint` callback must return a `DebugAction` (`continue_`, `stop`, `stepOver`, etc.).

## Architecture

### Core Components
- **Environment**: Central configuration object
- **Template**: Template instances for rendering
- **Loader**: Abstract base for template loading
- **MapLoader**: In-memory template loader
- **FileSystemLoader**: File-based template loader

### Key Files
- `lib/src/environment.dart` - Environment class
- `lib/src/renderer.dart` - Template rendering
- `lib/src/loaders.dart` - Template loaders
- `lib/src/parser.dart` - Template parsing
- `lib/src/lexer.dart` - Template lexing
- `lib/src/debug/async_debug_renderer.dart` - Debug-aware async renderer

## Testing

### Test Commands
- `dart test` - Run all tests
- `dart analyze` - Static analysis
- `dart format .` - Format code

### Test Structure
- Unit tests for core functionality
- Integration tests for template rendering
- Example-driven development

## Memory Bank

Project memory files are stored in `.serena/memories/`:
- `project_purpose.md` - Project overview
- `activeContext.md` - Current work and priorities
- `progress.md` - Sprint status and achievements
- `buildPlan.md` - Build plan and sync log
- `systemPatterns.md` - Code patterns and conventions
- `techContext.md` - Technology stack details
- `productContext.md` - Product context and features

## Learned User Preferences
- Use `dart run example/<file>.dart` to verify specific example functionality.
- Add and expand async example coverage, especially macro-focused async scenarios.
- When a behavior is added, ensure example output visibly demonstrates it (not just data setup).
- Include practical repo scripts for example validation with a clear pass/fail summary.
- Prioritize fixing lints in core library files (`lib/src/`).
- Debugging features should be robust and match Jinja2 capabilities.
- When implementing `visitSlice`, handle `String` values by splitting, slicing, and re-joining.
- In example setups, load Jinja scripts by reading from files rather than hardcoding string literals.


## Learned Workspace Facts
- `example/get_jinja.dart` is a utility script that provides a pre-configured environment; it does not have a `main` function and should mirror `environment.py`.
- `AsyncDebugRenderer` is the primary renderer used for `renderDebug`.
- Debug actions (`stop`, `stepOver`) are critical; `onBreakpoint` must return a `DebugAction`.
- `DebugStoppedException` is used to interrupt rendering.
- Template rendering in `defaults.dart` supports python-like numeric formatting.
- `TemplateSyntaxError` field redundancy was removed to align with the base `TemplateError` implementation.
- Test coverage significantly improved: `lib/src/filters.dart` (91.6%), `lib/src/environment.dart` (91.9%), `lib/src/exceptions.dart` (>95%), `lib/src/renderer.dart` (82.9%).
- The engine supports a Python-like `.items()` method on dictionaries for key-value iteration in templates.
- Async functions within imported macros (via `MapLoader`) properly await future filters or globals in the async renderers.


## Last Updated
2026-03-25
