# Feature Specification: S3 Cross-Account Copy Task

**Feature Branch**: `001-id-like-to`
**Created**: 2025-09-22
**Status**: Draft
**Input**: User description: "Id like to create an airflow task in the airflow directory that is capable of making a request to amazon S3 and copies a file or entire prefix to another s3 bucket. These buckets may be across different AWS accounts. The task should provide metrics on number of files transferred, how long the transfer took, and any errors along the way. For transient errors (like network errors), the copy command should retry. The inputs to this task are a source bucket and source key or prefix, and a destination bucket, and destination prefix or key. A 'recursive' option must be provided when utilizing the source and destination prefixes. If possible, the copy command should copy directly from the source bucket to the destination bucket without transferring files locally (e.g. no bent pipe transfers)."

## Execution Flow (main)
```
1. Parse user description from Input
   � If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   � Identify: actors, actions, data, constraints
3. For each unclear aspect:
   � Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   � If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   � Each requirement must be testable
   � Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   � If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   � If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## � Quick Guidelines
-  Focus on WHAT users need and WHY
- L Avoid HOW to implement (no tech stack, APIs, code structure)
- =e Written for business stakeholders, not developers

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a data operations engineer, I need to copy large datasets between S3 buckets across different AWS accounts as part of automated data workflows, so that data can be efficiently distributed to various environments and external partners without manual intervention or local storage requirements.

### Acceptance Scenarios
1. **Given** a source S3 bucket with files in account A and a destination bucket in account B, **When** the copy task is executed with source and destination parameters, **Then** all specified files are copied directly between buckets and metrics are recorded
2. **Given** a source S3 prefix containing multiple files, **When** the copy task is executed with recursive option enabled, **Then** all files under the prefix are copied maintaining directory structure
3. **Given** a network timeout occurs during copy operation, **When** the transient error is detected, **Then** the task automatically retries the failed operation and continues processing
4. **Given** copy operation completes successfully, **When** the task finishes, **Then** comprehensive metrics are provided including file count, transfer duration, and any errors encountered

### Edge Cases
- What happens when source bucket/key does not exist? (System must fail gracefully with clear error message)
- What happens when destination bucket lacks write permissions? (System must fail with permission error before starting transfer)
- How does system handle very large files or prefixes with thousands of objects? (System must process in batches and provide progress updates)
- What happens when network connectivity is intermittent? (System must retry individual operations per retry policy)
- How does system handle duplicate files in destination? (System must overwrite existing files by default)

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST copy files directly between S3 buckets without downloading to local storage
- **FR-002**: System MUST support cross-account S3 operations with proper authentication
- **FR-003**: System MUST accept source bucket, source key/prefix, destination bucket, and destination key/prefix as inputs
- **FR-004**: System MUST provide recursive copy option for prefix-based operations
- **FR-005**: System MUST retry operations on transient errors with maximum 3 attempts using exponential backoff (1s, 2s, 4s delays)
- **FR-006**: System MUST collect and report metrics on files transferred count
- **FR-007**: System MUST measure and report total transfer duration
- **FR-008**: System MUST capture and report any errors encountered during operations
- **FR-009**: System MUST preserve source file metadata during copy operations
- **FR-010**: System MUST validate inputs before starting copy operations
- **FR-011**: System MUST handle both single file and prefix-based copy operations
- **FR-012**: System MUST operate within Airflow task framework for workflow integration
- **FR-013**: System MUST validate source and destination existence and permissions before starting transfer
- **FR-014**: System MUST process large prefix operations in batches to handle thousands of objects efficiently
- **FR-015**: System MUST overwrite existing files in destination by default

### Key Entities
- **Copy Operation**: Represents a single S3 copy task with source location, destination location, options, and execution status
- **Transfer Metrics**: Contains quantitative data about copy operation including file count, duration, errors, and completion status
- **S3 Location**: Represents source or destination with bucket name, key/prefix, and account context

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---