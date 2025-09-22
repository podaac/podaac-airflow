<!--
Sync Impact Report:
Version change: 0.0.0 → 1.0.0
New constitution created with:
- 5 core principles for data workflow automation
- Infrastructure and operational sections
- Governance framework
Templates requiring updates: ✅ All existing templates compatible
-->

# PO.DAAC Airflow Constitution

## Core Principles

### I. Infrastructure as Code
All infrastructure MUST be defined as code using Terraform. No manual infrastructure changes are permitted. Infrastructure changes require code review, automated testing, and documentation. Configuration drift detection MUST be implemented and remediated promptly.

### II. Container-First Deployment
All applications MUST be containerized and deployed using Kubernetes. Base images MUST be from official sources with pinned versions. Security scanning MUST be performed on all container images before deployment.

### III. Automated Data Processing (NON-NEGOTIABLE)
All data workflows MUST be implemented as Airflow DAGs with explicit dependencies. Manual data processing steps are prohibited except for emergency situations. All workflows MUST include error handling, retry logic, and comprehensive logging.

### IV. Monitoring and Observability
All workflows MUST emit structured logs and metrics. Status reporting MUST be automated with real-time dashboards. Alert thresholds MUST be defined for all critical data processing paths. AWS Step Functions status MUST be tracked and reported.

### V. AWS Integration Standards
All AWS resources MUST follow least-privilege access patterns. AWS services integration MUST use official Airflow providers. Cross-service authentication MUST use IAM roles, never hardcoded credentials. Resource tagging MUST follow NASA/PO.DAAC standards.

## Infrastructure Standards

Infrastructure deployments MUST use the approved Terraform modules located in the terraform/ directory. All Kubernetes resources MUST be deployed through Helm charts with versioned releases. EKS cluster configuration MUST follow the unity-sps pattern with Karpenter for auto-scaling. Resource limits and requests MUST be defined for all workloads.

## Operational Requirements

Pre-commit hooks MUST be configured and passing for all changes. Terraform validation, formatting, linting, and security scanning MUST pass before merge. All DAGs MUST be tested in a development environment before production deployment. Plugin development MUST follow the established patterns in the plugins/ directory.

## Governance

This constitution supersedes all other development practices and operational procedures. All pull requests MUST be reviewed for constitutional compliance. Infrastructure changes require approval from platform engineering. DAG changes require approval from data operations team.

Amendments to this constitution require documentation of impact, migration plan, and approval from project stakeholders. Complexity in workflows or infrastructure MUST be justified with clear business requirements.

**Version**: 1.0.0 | **Ratified**: 2025-09-22 | **Last Amended**: 2025-09-22