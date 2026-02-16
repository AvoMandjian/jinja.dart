# Tasks: Increase Test Coverage

**Status**: 🔄 **IN PROGRESS**

**Goal**: Increase test coverage from 64.61% (3,783/5,855 statements) to 80%+ (4,684+ statements)

**Current Coverage**: 72.36% (4,031 / 5,571 statements covered)
**Target Coverage**: 80%+ (4,684+ statements covered)
**Gap**: ~400 statements need coverage

---

## Phase 0: Baseline & Analysis

- [x] T001: Measure current coverage baseline
- [x] T002: Analyze existing test patterns
- [x] T003: Identify coverage gaps

---

## Phase 1: Core Utilities & Common Logic (High Impact)

### Utils Tests (`test/utils_test.dart`)

- [x] T004: Create `test/utils_test.dart` file
- [x] T005-T016: Test utility functions (boolean, identity, pair, iterate, list, range, escape, capitalize, stripTags, sum, htmlSafeJsonEncode, errorContextSnippet)

### Reader Tests (`test/reader_test.dart`)

- [x] T017: Create `test/reader_test.dart` file
- [x] T018-T025: Test `TokenReader`, `TokenIterable`, `TokenIterator`

### Visitor Tests (`test/visitor_test.dart`)

- [x] T067: Create `test/visitor_test.dart`
- [x] T068: Test `ThrowingVisitor` default implementations

- [x] T026: Verify Phase 1 coverage

---

## Phase 2: AST Nodes & Compiler Tests (High Impact)

### Node Tests (`test/nodes_test.dart`)

- [x] T069: Create `test/nodes_test.dart`
- [x] T070-T073: Test `toJson()`, `toSource()`, `copyWith()`, `findAll()` on all node types

### Compiler Tests (`test/compiler_test.dart`)

- [ ] T027: Create `test/compiler_test.dart` file
- [ ] T028-T036: Test AST transformations

- [x] T037: Verify Phase 2 coverage

---

## Phase 3: Optimizer & Evaluator Tests (Medium Complexity)

### Optimizer Tests (`test/optimizer_test.dart`)

- [x] T038: Create `test/optimizer_test.dart` file
- [x] T039-T048: Test constant folding and visit methods

### Evaluator Tests (`test/evaluator_test.dart`)

- [x] T074: Create `test/evaluator_test.dart`
- [x] T075: Test `ExpressionEvaluator` implementations and errors

- [x] T049: Verify Phase 3 coverage

---

## Phase 4: Runtime & Renderer Tests (High Complexity)

### Runtime Tests (`test/runtime_test.dart`)

- [x] T050: Create `test/runtime_test.dart` file
- [x] T051-T060: Test `Context`, `LoopContext`, `Cycler`

### Renderer Tests (`test/renderer_test.dart`)

- [x] T076: Create `test/renderer_test.dart`
- [x] T077: Test `assignTargets` edge cases
- [x] T078: Test `AsyncRenderContext` methods

### Environment Tests (`test/environment_test.dart`)

- [ ] T079: Create `test/environment_test.dart`
- [ ] T080: Test `hashCode`, `operator ==`, `newLine` validation
- [ ] T081: Test `lex`, `parse`, `scan` convenience methods

### FileSystemLoader Enhancement

- [x] T082: Update `test/file_system_loader_test.dart` with missing branches

- [ ] T061: Verify Phase 4 coverage

---

## Phase 5: Coverage Verification & Documentation

- [ ] T062: Run final coverage analysis
- [ ] T063: Document coverage improvements
- [ ] T064: Verify all tests pass
- [ ] T065: Code quality checks
- [ ] T066: Document remaining gaps

---

## Success Criteria

- [x] All new test files created
- [ ] Test coverage increased to 80%+ (4,684+ statements covered)
- [x] All tests pass (no regressions)
- [ ] Code formatted and analyzed (zero lint errors)
- [ ] Coverage improvements documented
