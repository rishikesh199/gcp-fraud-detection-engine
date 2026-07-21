# CI/CD Pipelines (GitHub Actions)

## 📌 Enterprise Purpose
This module contains the automated Continuous Integration and Continuous Deployment (CI/CD) pipelines. In an enterprise data engineering environment, pushing untested code can corrupt the data warehouse or break critical streaming pipelines. These workflows ensure that all code is rigorously tested, formatted, and validated before being merged into the `main` branch.

## 🔄 Automated Workflows

### 1. Terraform Plan & Validation
- **Trigger:** Pull Request to `main`.
- **Purpose:** Runs `terraform fmt -check`, `terraform validate`, and `terraform plan`. It outputs the infrastructure changes directly into the PR comments, preventing accidental cloud resource destruction.

### 2. dbt CI Testing
- **Trigger:** Pull Request modifying `/dbt_fraud/**`.
- **Purpose:** Compiles the dbt SQL models (`dbt compile`) and runs data quality tests (`dbt test`) against a temporary staging dataset in BigQuery to ensure new logic doesn't break existing facts and dimensions.

### 3. Python Unit Testing (Pytest)
- **Trigger:** Push to `main` or PR.
- **Purpose:** Executes Pytest on the `/tests` directory to validate the PySpark UDFs, Dataflow DoFns, and the Data Generator logic.

## 📦 Tech Stack
- **Platform:** GitHub Actions (`.yml`)
- **Runners:** `ubuntu-latest`
- **Secrets Management:** GitHub Action Secrets (Injecting GCP Service Account JSON keys).
