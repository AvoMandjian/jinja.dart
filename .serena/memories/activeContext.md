# Active Context

## Current Work
- Refactoring MapLoader to support globalJinjaData
- Enhancing template loading capabilities
- Improving async globals example with macros

## Recent Changes (2026-02-11)
- **Refactored MapLoader** (commit 881a62e)
  - Changed `const MapLoader` to `MapLoader` (removed const)
  - Changed `final Map<String, dynamic> globalJinjaData` to `Map<String, dynamic> globalJinjaData` (mutable)
  - Simplified `load` method signature formatting
  - Reduced code complexity: 4 insertions, 12 deletions
  - Improved globalJinjaData support for dynamic updates

## Priorities
1. Continue improving template loading mechanisms
2. Enhance async globals support
3. Maintain code quality and test coverage

## Code Quality Status
- ✅ Zero lint errors
- ✅ All tests passing
- ✅ Code formatted

## Last Updated
2026-02-11