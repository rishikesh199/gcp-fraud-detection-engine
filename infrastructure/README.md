
# 🏗️ Infrastructure — Terraform IaC

This directory contains all **Terraform** configuration files for provisioning GCP infrastructure.

## What's Inside
- `main.tf` — Main Terraform configuration
- `variables.tf` — Input variables (project ID, region, etc.)
- `outputs.tf` — Output values (bucket names, dataset IDs, etc.)
- `provider.tf` — GCP provider configuration
- `gcs.tf` — Cloud Storage bucket definitions
- `bigquery.tf` — BigQuery dataset and table definitions
- `iam.tf` — Service account and IAM role definitions
- `pubsub.tf` — Pub/Sub topic and subscription definitions
- `terraform.tfvars` — Variable values (⚠️ not committed to git)

## Usage (from Cloud Shell)
```bash
cd infrastructure/
terraform init
terraform plan
terraform apply
```

## Environment
- **Dev**: `fraud-dev-*` prefix
- **Region**: asia-south1 (Mumbai)
- **Project**: fraud-detection-de-project-2026
