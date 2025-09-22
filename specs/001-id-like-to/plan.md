
# Implementation Plan: S3 Cross-Account Copy Task

**Branch**: `001-id-like-to` | **Date**: 2025-09-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Users/gangl/dev/podaac/podaac-airflow/specs/001-id-like-to/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Create a reusable Airflow task for S3 cross-account file copying with direct bucket-to-bucket transfers, IAM role-based authentication, comprehensive metrics logging, and automatic retry logic for transient errors. Task will support both single file and recursive prefix operations.

## Technical Context
**Language/Version**: Python 3.11 (Airflow 2.10.5)
**Primary Dependencies**: Apache Airflow, boto3, apache-airflow-providers-amazon
**Storage**: S3 object storage (source and destination buckets)
**Testing**: pytest with Airflow test utilities
**Target Platform**: Kubernetes pods via Airflow KubernetesPodOperator
**Project Type**: single (Airflow plugin/task)
**Performance Goals**: Handle thousands of objects efficiently, sub-second per file for small files
**Constraints**: IAM role-based authentication only, no local storage, direct S3-to-S3 transfers
**Scale/Scope**: Support enterprise data workflows with TB-scale transfers, cross-account operations

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**✅ III. Automated Data Processing (NON-NEGOTIABLE)**: Task will be implemented as reusable Airflow component with explicit error handling, retry logic, and comprehensive logging.

**✅ IV. Monitoring and Observability**: Task will emit structured logs with metrics (file count, duration, errors) to Airflow logs for monitoring.

**✅ V. AWS Integration Standards**: Using IAM roles for authentication (no hardcoded credentials), official Airflow providers (apache-airflow-providers-amazon), following least-privilege access patterns.

**✅ Container-First Deployment**: Task runs within existing Airflow container infrastructure on Kubernetes.

**✅ Infrastructure as Code**: Task will be deployed as part of existing Airflow DAG framework, no additional infrastructure changes required.

**CONSTITUTIONAL COMPLIANCE**: PASS - All principles satisfied.

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure]
```

**Structure Decision**: Option 1 (Single project) - Airflow plugin structure with task implementation in existing plugins/ directory

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate contract tests** from contracts:
   - One test file per endpoint
   - Assert request/response schemas
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Each story → integration test scenario
   - Quickstart test = story validation steps

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
     **IMPORTANT**: Execute it exactly as specified above. Do not add or remove any arguments.
   - If exists: Add only NEW tech from current plan
   - Preserve manual additions between markers
   - Update recent changes (keep last 3)
   - Keep under 150 lines for token efficiency
   - Output to repository root

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Contract interface → contract test task [P]
- S3CopyOperation entity → operator class creation task [P]
- MetricsCollector entity → metrics collection task [P]
- Integration tests from user scenarios
- Implementation tasks following TDD pattern

**Ordering Strategy**:
- TDD order: Contract tests → Models → Operator implementation → Integration tests
- Plugin structure: Base operator → Metrics collector → Integration → Testing
- Mark [P] for parallel execution (different files, no dependencies)
- Sequential for related components (operator depends on models)

**Estimated Output**: 20-25 numbered, ordered tasks in tasks.md

**Key Task Categories**:
1. Setup: Plugin structure, dependencies, configuration
2. Tests: Contract tests for operator interface
3. Models: S3CopyOperation, TransferMetrics, S3Object classes
4. Core: S3CrossAccountCopyOperator implementation
5. Integration: Airflow provider integration, IAM role handling
6. Validation: Integration tests, quickstart verification

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
