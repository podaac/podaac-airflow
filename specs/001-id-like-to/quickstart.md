# Quickstart: S3 Cross-Account Copy Task

## Prerequisites

1. **Airflow Environment**: Running PO.DAAC Airflow deployment
2. **AWS Connections**: Configured Airflow connections for source and destination AWS accounts
3. **IAM Permissions**: Appropriate cross-account IAM roles for S3 access

## Basic Usage

### Single File Copy

```python
from airflow import DAG
from datetime import datetime
from plugins.s3_copy_plugin.operators import S3CrossAccountCopyOperator

dag = DAG(
    'example_s3_copy',
    start_date=datetime(2025, 1, 1),
    schedule_interval=None
)

copy_single_file = S3CrossAccountCopyOperator(
    task_id='copy_single_file',
    source_bucket='source-account-bucket',
    source_key='data/file.txt',
    destination_bucket='dest-account-bucket',
    destination_key='copied-data/file.txt',
    source_aws_conn_id='aws_source_account',
    dest_aws_conn_id='aws_dest_account',
    dag=dag
)
```

### Recursive Prefix Copy

```python
copy_prefix_recursive = S3CrossAccountCopyOperator(
    task_id='copy_prefix_recursive',
    source_bucket='source-account-bucket',
    source_key='datasets/daily/',
    destination_bucket='dest-account-bucket',
    destination_key='backup/datasets/daily/',
    recursive=True,
    batch_size=50,
    source_aws_conn_id='aws_source_account',
    dest_aws_conn_id='aws_dest_account',
    dag=dag
)
```

## Configuration Options

### Required Parameters
- `source_bucket`: Source S3 bucket name
- `source_key`: Source S3 key or prefix
- `destination_bucket`: Destination S3 bucket name
- `destination_key`: Destination S3 key or prefix

### Optional Parameters
- `recursive`: Enable recursive copying for prefixes (default: False)
- `source_aws_conn_id`: Airflow connection for source account (default: None)
- `dest_aws_conn_id`: Airflow connection for destination account (default: None)
- `batch_size`: Objects to process per batch (default: 100)
- `overwrite`: Overwrite existing files (default: True)

## AWS Connection Setup

### Source Account Connection
1. Go to Airflow Admin → Connections
2. Create new connection:
   - **Connection Id**: `aws_source_account`
   - **Connection Type**: `Amazon Web Services`
   - **Extra**: `{"role_arn": "arn:aws:iam::SOURCE-ACCOUNT:role/AirflowS3Access"}`

### Destination Account Connection
1. Create new connection:
   - **Connection Id**: `aws_dest_account`
   - **Connection Type**: `Amazon Web Services`
   - **Extra**: `{"role_arn": "arn:aws:iam::DEST-ACCOUNT:role/AirflowS3Access"}`

## IAM Role Configuration

### Source Account Role Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::source-bucket",
                "arn:aws:s3:::source-bucket/*"
            ]
        }
    ]
}
```

### Destination Account Role Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::dest-bucket/*"
            ]
        }
    ]
}
```

## Testing the Implementation

### Test Single File Copy
```python
# Test DAG for single file validation
test_single_copy = S3CrossAccountCopyOperator(
    task_id='test_single_copy',
    source_bucket='test-source-bucket',
    source_key='test-file.txt',
    destination_bucket='test-dest-bucket',
    destination_key='copied-test-file.txt',
    source_aws_conn_id='aws_test_source',
    dest_aws_conn_id='aws_test_dest'
)
```

### Test Recursive Copy
```python
# Test DAG for recursive prefix validation
test_recursive_copy = S3CrossAccountCopyOperator(
    task_id='test_recursive_copy',
    source_bucket='test-source-bucket',
    source_key='test-prefix/',
    destination_bucket='test-dest-bucket',
    destination_key='copied-prefix/',
    recursive=True,
    batch_size=10
)
```

## Expected Metrics Output

### Log Format
```
INFO - S3 Copy Operation Started: operation_id=copy_20250922_123456
INFO - Files discovered for copying: 150
INFO - Batch 1/15: Processing 10 files
INFO - Batch 1/15: Successfully copied 10 files, 0 failures
INFO - S3 Copy Operation Completed: {
    "operation_id": "copy_20250922_123456",
    "duration_seconds": 45.2,
    "total_files_found": 150,
    "files_copied_successfully": 150,
    "files_failed": 0,
    "total_bytes_transferred": 2048576000,
    "errors": []
}
```

### Error Handling
```
ERROR - S3 Copy Operation Failed: operation_id=copy_20250922_123456
ERROR - Validation Error: Source bucket 'invalid-bucket' does not exist
ERROR - Copy failed for key 'large-file.bin': Network timeout after 3 retries
```

## Troubleshooting

### Common Issues
1. **Permission Denied**: Check IAM role policies and cross-account trust relationships
2. **Connection Not Found**: Verify AWS connection IDs exist in Airflow
3. **Source Not Found**: Validate source bucket and key exist and are accessible
4. **Network Timeouts**: Check network connectivity and consider smaller batch sizes

### Validation Checklist
- [ ] AWS connections configured in Airflow
- [ ] IAM roles have proper S3 permissions
- [ ] Cross-account trust relationships established
- [ ] Source bucket and key exist
- [ ] Destination bucket exists and is writable
- [ ] Network connectivity between Airflow and AWS regions