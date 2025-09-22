"""
Contract definition for S3CrossAccountCopyOperator

This defines the expected interface and behavior for the Airflow operator
that will perform S3 cross-account copying operations.
"""

from typing import Optional, Dict, Any, List
from abc import ABC, abstractmethod
from datetime import datetime


class S3CopyOperatorInterface(ABC):
    """Abstract interface defining the contract for S3 copy operations."""

    @abstractmethod
    def __init__(
        self,
        source_bucket: str,
        source_key: str,
        destination_bucket: str,
        destination_key: str,
        recursive: bool = False,
        source_aws_conn_id: Optional[str] = None,
        dest_aws_conn_id: Optional[str] = None,
        batch_size: int = 100,
        overwrite: bool = True,
        **kwargs
    ):
        """
        Initialize the S3 copy operator.

        Args:
            source_bucket: Name of source S3 bucket
            source_key: Source S3 key or prefix
            destination_bucket: Name of destination S3 bucket
            destination_key: Destination S3 key or prefix
            recursive: Whether to copy recursively for prefixes
            source_aws_conn_id: Airflow connection for source account
            dest_aws_conn_id: Airflow connection for destination account
            batch_size: Number of objects to process per batch
            overwrite: Whether to overwrite existing files
        """
        pass

    @abstractmethod
    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the S3 copy operation.

        Args:
            context: Airflow task execution context

        Returns:
            Dict containing operation metrics and results

        Expected return format:
        {
            "operation_id": str,
            "duration_seconds": float,
            "total_files_found": int,
            "files_copied_successfully": int,
            "files_failed": int,
            "total_bytes_transferred": int,
            "errors": List[str]
        }
        """
        pass

    @abstractmethod
    def validate_inputs(self) -> bool:
        """
        Validate all input parameters before execution.

        Returns:
            True if all inputs are valid

        Raises:
            ValueError: If any input validation fails
        """
        pass

    @abstractmethod
    def get_s3_objects_to_copy(self) -> List[Dict[str, Any]]:
        """
        Discover and list all S3 objects that need to be copied.

        Returns:
            List of S3 object metadata dictionaries

        Expected object format:
        {
            "bucket": str,
            "key": str,
            "size": int,
            "last_modified": datetime,
            "etag": str
        }
        """
        pass

    @abstractmethod
    def copy_single_object(
        self,
        source_bucket: str,
        source_key: str,
        dest_bucket: str,
        dest_key: str
    ) -> Dict[str, Any]:
        """
        Copy a single S3 object from source to destination.

        Args:
            source_bucket: Source bucket name
            source_key: Source object key
            dest_bucket: Destination bucket name
            dest_key: Destination object key

        Returns:
            Dict with copy result metadata

        Expected return format:
        {
            "success": bool,
            "bytes_transferred": int,
            "error_message": Optional[str]
        }
        """
        pass


class MetricsCollectorInterface(ABC):
    """Interface for collecting and reporting transfer metrics."""

    @abstractmethod
    def start_operation(self, operation_id: str) -> None:
        """Mark the start of a copy operation."""
        pass

    @abstractmethod
    def record_file_success(self, bytes_transferred: int) -> None:
        """Record successful file transfer."""
        pass

    @abstractmethod
    def record_file_failure(self, error_message: str) -> None:
        """Record failed file transfer."""
        pass

    @abstractmethod
    def finish_operation(self) -> Dict[str, Any]:
        """Complete operation and return final metrics."""
        pass