# Baseline Coverage Metrics

**Date**: 2026-02-12  
**Total Coverage**: 3610 / 5535 (65.22%)

## File Coverage Summary

| File | Hit / Total | Percentage |
|------|-------------|------------|
| lib/loaders.dart | 12 / 33 | 36.36% |
| lib/src/compiler.dart | 224 / 239 | 93.72% |
| lib/src/debug/async_debug_renderer.dart | 75 / 252 | 29.76% |
| lib/src/debug/debug_controller.dart | 18 / 36 | 50.00% |
| lib/src/debug/debug_renderer.dart | 26 / 79 | 32.91% |
| lib/src/debug/debug_template.dart | 13 / 15 | 86.67% |
| lib/src/debug/evaluator.dart | 1 / 100 | 1.00% |
| lib/src/defaults.dart | 93 / 154 | 60.39% |
| lib/src/environment.dart | 138 / 259 | 53.28% |
| lib/src/error_logger.dart | 41 / 44 | 93.18% |
| lib/src/exceptions.dart | 141 / 195 | 72.31% |
| lib/src/filters.dart | 348 / 524 | 66.41% |
| lib/src/lexer.dart | 224 / 249 | 89.96% |
| lib/src/loaders.dart | 11 / 22 | 50.00% |
| lib/src/nodes.dart | 50 / 95 | 52.63% |
| lib/src/nodes/expressions.dart | 183 / 338 | 54.14% |
| lib/src/nodes/statements.dart | 181 / 390 | 46.41% |
| lib/src/optimizer.dart | 197 / 216 | 91.20% |
| lib/src/parser.dart | 624 / 699 | 89.27% |
| lib/src/reader.dart | 47 / 49 | 95.92% |
| lib/src/renderer.dart | 557 / 892 | 62.44% |
| lib/src/runtime.dart | 137 / 260 | 52.69% |
| lib/src/tests.dart | 92 / 109 | 84.40% |
| lib/src/token.dart | 26 / 33 | 78.79% |
| lib/src/utils.dart | 150 / 163 | 92.02% |
| lib/src/visitor.dart | 1 / 90 | 1.11% |

## Primary Gaps

1. **Visitor/Nodes**: `visitor.dart` (1.11%), `nodes/statements.dart` (46.41%), `nodes/expressions.dart` (54.14%)
2. **Debug Module**: `evaluator.dart` (1.00%), `async_debug_renderer.dart` (29.76%), `debug_renderer.dart` (32.91%)
3. **Core Runtime**: `environment.dart` (53.28%), `runtime.dart` (52.69%), `loaders.dart` (36.36%-50.00%)
4. **Renderer**: `renderer.dart` (62.44%)
