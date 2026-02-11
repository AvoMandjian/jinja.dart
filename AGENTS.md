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

## Common Tasks

### Development Workflow
1. Make changes
2. Run `dart format .`
3. Run `dart analyze`
4. Run `dart test`
5. Update documentation if needed

### Code Quality
- Zero lint errors required
- All tests must pass
- Follow existing code patterns
- Maintain backward compatibility

## Last Updated
2026-02-11
