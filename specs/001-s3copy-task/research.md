# Research: S3 Cross-Account Copy Task

## S3 Cross-Account Copy Methods

**Decision**: Use boto3 S3 client with copy_object() method for direct bucket-to-bucket transfers

**Rationale**:
- copy_object() performs server-side copy without downloading to local storage
- Supports cross-account operations with proper IAM role configuration
- Native boto3 integration with Airflow providers
- Efficient for both single files and can be orchestrated for prefix operations

**Alternatives Considered**:
- AWS DataSync: Overkill for programmatic copying, requires additional infrastructure
- S3 Transfer Manager: Good for large files but adds complexity
- Manual get/put operations: Violates requirement for direct transfers

## Airflow Task Implementation Pattern

**Decision**: Create custom BaseOperator extending existing Airflow S3 patterns

**Rationale**:
- Follows Airflow best practices for reusable operators
- Integrates with existing apache-airflow-providers-amazon patterns
- Supports Airflow's retry and logging mechanisms natively
- Can be easily included in DAGs as standard task

**Alternatives Considered**:
- PythonOperator with S3 functions: Less reusable, harder to test
- Existing S3CopyObjectOperator: Doesn't support prefix operations or cross-account scenarios
- Custom plugin: More complex deployment, unnecessary for single operator

## IAM Role Configuration for Cross-Account

**Decision**: Use Airflow connection with IAM role assumption for cross-account access

**Rationale**:
- Follows AWS security best practices
- No credentials stored in code or configuration
- Leverages existing Airflow connection management
- Supports multiple account scenarios

**Alternatives Considered**:
- Cross-account bucket policies: Less flexible, requires destination account configuration
- STS temporary credentials: Adds complexity, managed by Airflow connection already
- Access keys: Violates security requirements

## Retry and Error Handling Strategy

**Decision**: Combine Airflow task retries with custom boto3 retry configuration

**Rationale**:
- Airflow handles task-level retries (infrastructure failures)
- Boto3 handles transient S3 API errors
- Exponential backoff built into both layers
- Clear separation of retry reasons

**Alternatives Considered**:
- Only Airflow retries: Doesn't handle S3-specific transient errors efficiently
- Only boto3 retries: Doesn't handle pod/infrastructure failures
- Custom retry logic: Reinvents existing battle-tested mechanisms

## Metrics and Logging Approach

**Decision**: Use structured logging with Airflow's logging framework

**Rationale**:
- Integrates with existing log aggregation systems
- Supports structured data for metrics extraction
- No additional infrastructure required
- Follows observability principle from constitution

**Alternatives Considered**:
- CloudWatch custom metrics: Requires additional AWS permissions and cost
- Prometheus metrics: Not part of existing monitoring stack
- Database logging: Adds infrastructure complexity

## Batch Processing for Large Prefix Operations

**Decision**: Use S3 list_objects_v2 with pagination and process in configurable batches

**Rationale**:
- Handles thousands of objects efficiently
- Configurable batch size for different use cases
- Built-in pagination support in boto3
- Progress tracking capabilities

**Alternatives Considered**:
- Process all objects at once: Memory and timeout issues
- Single object processing: Inefficient for large datasets
- S3 Inventory reports: Too complex for real-time operations