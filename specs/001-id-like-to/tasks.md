# Tasks: S3 Cross-Account Copy Task

**Input**: Design documents from `/Users/gangl/dev/podaac/podaac-airflow/specs/001-id-like-to/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/, quickstart.md

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Airflow plugin structure**: `plugins/s3_copy_plugin/` for implementation
- **Tests**: `tests/` at repository root
- Paths are absolute for this Airflow project

## Phase 3.1: Setup
- [ ] T001 Create S3 copy plugin directory structure in plugins/s3_copy_plugin/
- [ ] T002 Initialize Python module with __init__.py and dependency imports in plugins/s3_copy_plugin/__init__.py
- [ ] T003 [P] Configure plugin registration for Airflow in plugins/s3_copy_plugin/plugin.py

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T004 [P] Contract test for S3CopyOperatorInterface in tests/contract/test_s3_copy_operator_interface.py
- [ ] T005 [P] Contract test for MetricsCollectorInterface in tests/contract/test_metrics_collector_interface.py
- [ ] T006 [P] Integration test single file copy scenario in tests/integration/test_single_file_copy.py
- [ ] T007 [P] Integration test recursive prefix copy scenario in tests/integration/test_recursive_copy.py
- [ ] T008 [P] Integration test cross-account authentication in tests/integration/test_cross_account_auth.py
- [ ] T009 [P] Integration test retry logic and error handling in tests/integration/test_retry_logic.py

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T010 [P] S3CopyOperation model class in plugins/s3_copy_plugin/models/s3_copy_operation.py
- [ ] T011 [P] TransferMetrics model class in plugins/s3_copy_plugin/models/transfer_metrics.py
- [ ] T012 [P] S3Object model class in plugins/s3_copy_plugin/models/s3_object.py
- [ ] T013 [P] MetricsCollector service in plugins/s3_copy_plugin/services/metrics_collector.py
- [ ] T014 S3CrossAccountCopyOperator main implementation in plugins/s3_copy_plugin/operators/s3_cross_account_copy_operator.py
- [ ] T015 Input validation logic in plugins/s3_copy_plugin/operators/s3_cross_account_copy_operator.py
- [ ] T016 S3 object discovery and listing in plugins/s3_copy_plugin/operators/s3_cross_account_copy_operator.py
- [ ] T017 Single object copy method with boto3 in plugins/s3_copy_plugin/operators/s3_cross_account_copy_operator.py
- [ ] T018 Batch processing for prefix operations in plugins/s3_copy_plugin/operators/s3_cross_account_copy_operator.py

## Phase 3.4: Integration
- [ ] T019 IAM role assumption for cross-account access in plugins/s3_copy_plugin/services/aws_connection_manager.py
- [ ] T020 Boto3 retry configuration and error handling in plugins/s3_copy_plugin/services/boto3_retry_handler.py
- [ ] T021 Airflow logging integration and structured metrics output in plugins/s3_copy_plugin/operators/s3_cross_account_copy_operator.py
- [ ] T022 Plugin registration and operator export in plugins/s3_copy_plugin/plugin.py

## Phase 3.5: Polish
- [ ] T023 [P] Unit tests for S3CopyOperation validation in tests/unit/test_s3_copy_operation.py
- [ ] T024 [P] Unit tests for TransferMetrics calculations in tests/unit/test_transfer_metrics.py
- [ ] T025 [P] Unit tests for MetricsCollector functionality in tests/unit/test_metrics_collector.py
- [ ] T026 [P] Performance tests for large prefix operations (thousands of objects) in tests/performance/test_large_prefix_performance.py
- [ ] T027 [P] Performance tests for cross-account latency (<1s per small file) in tests/performance/test_cross_account_performance.py
- [ ] T028 [P] Update quickstart.md with final usage examples and validation scenarios
- [ ] T029 End-to-end validation test using quickstart scenarios in tests/e2e/test_quickstart_scenarios.py
- [ ] T030 Code review and refactoring for constitutional compliance

## Dependencies
- Setup (T001-T003) before everything else
- Tests (T004-T009) before implementation (T010-T018)
- Models (T010-T012) before services (T013) and operators (T014-T018)
- Core implementation (T010-T018) before integration (T019-T022)
- Integration (T019-T022) before polish (T023-T030)
- T014 blocks T015, T016, T017, T018 (same file modifications)
- T019 required for T021 (AWS connection needed for logging integration)

## Parallel Example
```
# Launch setup tasks together:
Task: "Create S3 copy plugin directory structure in plugins/s3_copy_plugin/"
Task: "Configure plugin registration for Airflow in plugins/s3_copy_plugin/plugin.py"

# Launch contract tests together:
Task: "Contract test for S3CopyOperatorInterface in tests/contract/test_s3_copy_operator_interface.py"
Task: "Contract test for MetricsCollectorInterface in tests/contract/test_metrics_collector_interface.py"

# Launch integration tests together:
Task: "Integration test single file copy scenario in tests/integration/test_single_file_copy.py"
Task: "Integration test recursive prefix copy scenario in tests/integration/test_recursive_copy.py"
Task: "Integration test cross-account authentication in tests/integration/test_cross_account_auth.py"
Task: "Integration test retry logic and error handling in tests/integration/test_retry_logic.py"

# Launch model creation together:
Task: "S3CopyOperation model class in plugins/s3_copy_plugin/models/s3_copy_operation.py"
Task: "TransferMetrics model class in plugins/s3_copy_plugin/models/transfer_metrics.py"
Task: "S3Object model class in plugins/s3_copy_plugin/models/s3_object.py"
Task: "MetricsCollector service in plugins/s3_copy_plugin/services/metrics_collector.py"
```

## Notes
- [P] tasks = different files, no dependencies between them
- Verify tests fail before implementing functionality
- Commit after each task completion
- Follow TDD strictly: Red (failing tests) → Green (minimal implementation) → Refactor
- Use IAM roles only, no hardcoded credentials
- All metrics output to Airflow structured logs
- Batch processing for efficiency with large prefix operations

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - s3_copy_operator_interface.py → contract test tasks T004, T005 [P]
   - Interface methods → implementation tasks T014-T018

2. **From Data Model**:
   - S3CopyOperation entity → model creation task T010 [P]
   - TransferMetrics entity → model creation task T011 [P]
   - S3Object entity → model creation task T012 [P]
   - MetricsCollector interface → service implementation task T013 [P]

3. **From Quickstart Scenarios**:
   - Single file copy → integration test T006 [P]
   - Recursive prefix copy → integration test T007 [P]
   - Cross-account setup → integration test T008 [P]
   - Error handling → integration test T009 [P]

4. **From Research Decisions**:
   - boto3 copy_object → implementation in T017
   - IAM role assumption → service in T019
   - Airflow logging → integration in T021
   - Batch processing → implementation in T018

## Validation Checklist
*GATE: Checked by main() before returning*

- [x] All contracts have corresponding tests (T004, T005)
- [x] All entities have model tasks (T010, T011, T012)
- [x] All tests come before implementation (T004-T009 before T010-T018)
- [x] Parallel tasks truly independent (different files, no shared state)
- [x] Each task specifies exact file path (plugins/s3_copy_plugin/*, tests/*)
- [x] No task modifies same file as another [P] task
- [x] TDD order maintained (tests → models → services → operators → integration)
- [x] Constitutional compliance verified (IAM roles, structured logging, Airflow integration)