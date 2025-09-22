# Data Model: S3 Cross-Account Copy Task

## Core Entities

### S3CopyOperation
**Purpose**: Represents a single copy operation with all required parameters and state

**Fields**:
- `source_bucket`: Source S3 bucket name (string, required)
- `source_key`: Source S3 key or prefix (string, required)
- `destination_bucket`: Destination S3 bucket name (string, required)
- `destination_key`: Destination S3 key or prefix (string, required)
- `recursive`: Enable recursive copying for prefixes (boolean, default: False)
- `source_aws_conn_id`: Airflow connection ID for source account (string, optional)
- `dest_aws_conn_id`: Airflow connection ID for destination account (string, optional)
- `batch_size`: Number of objects to process per batch (integer, default: 100)
- `overwrite`: Whether to overwrite existing files (boolean, default: True)

**Validation Rules**:
- All bucket names must be valid S3 bucket naming convention
- Keys cannot be empty strings
- Batch size must be between 1 and 1000
- AWS connection IDs must exist in Airflow connections if specified

**State Transitions**:
- INITIALIZED → VALIDATING → COPYING → COMPLETED
- Error states: VALIDATION_FAILED, COPY_FAILED

### TransferMetrics
**Purpose**: Collects quantitative data about copy operation progress and results

**Fields**:
- `operation_id`: Unique identifier for the operation (string)
- `start_time`: When operation began (datetime)
- `end_time`: When operation completed (datetime, nullable)
- `total_files_found`: Number of files discovered for copying (integer)
- `files_copied_successfully`: Number of files copied without error (integer)
- `files_failed`: Number of files that failed to copy (integer)
- `total_bytes_transferred`: Total bytes copied (integer)
- `errors_encountered`: List of error messages and details (list)

**Validation Rules**:
- Start time must be before end time
- File counts must be non-negative
- Total files found should equal sum of copied + failed
- Bytes transferred must be non-negative

### S3Object
**Purpose**: Represents individual S3 object being copied

**Fields**:
- `bucket`: S3 bucket name (string)
- `key`: S3 object key (string)
- `size`: Object size in bytes (integer)
- `last_modified`: Last modification date (datetime)
- `etag`: Object ETag for integrity checking (string)
- `metadata`: Object metadata dictionary (dict, optional)

**Relationships**:
- Multiple S3Objects belong to one S3CopyOperation
- S3Objects generate entries in TransferMetrics

**Validation Rules**:
- Bucket and key cannot be empty
- Size must be non-negative
- ETag must be valid S3 ETag format
- Last modified must be valid datetime

## Data Flow

```
S3CopyOperation (input parameters)
    ↓
List S3Objects (source discovery)
    ↓
Batch S3Objects (grouping for efficiency)
    ↓
Copy S3Objects (transfer execution)
    ↓
Update TransferMetrics (progress tracking)
    ↓
Final TransferMetrics (completion report)
```

## Configuration Schema

### Task Parameters
```python
{
    "source_bucket": "string",
    "source_key": "string",
    "destination_bucket": "string",
    "destination_key": "string",
    "recursive": "boolean",
    "source_aws_conn_id": "string|null",
    "dest_aws_conn_id": "string|null",
    "batch_size": "integer",
    "overwrite": "boolean"
}
```

### Metrics Output Schema
```python
{
    "operation_id": "string",
    "duration_seconds": "number",
    "total_files_found": "integer",
    "files_copied_successfully": "integer",
    "files_failed": "integer",
    "total_bytes_transferred": "integer",
    "errors": ["string"]
}
```