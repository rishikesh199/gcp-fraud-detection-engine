# 🔁 GitHub Actions — CI/CD Workflows

This directory contains **GitHub Actions** workflow definitions for automated CI/CD.

## What's Inside
- `ci.yml` — Continuous Integration (lint, test on every push)
- `deploy-streaming.yml` — Deploy Dataflow streaming pipeline
- `deploy-batch.yml` — Deploy PySpark jobs to GCS
- `terraform-plan.yml` — Terraform plan on PR (preview changes)
- `terraform-apply.yml` — Terraform apply on merge to main

## CI Pipeline (ci.yml)
Triggered on: Every push and pull request
1. Checkout code
2. Setup Python
3. Install dependencies
4. Run linting (flake8/ruff)
5. Run unit tests (pytest)
6. Report results

## CD Pipeline (deploy-*.yml)
Triggered on: Merge to main branch
1. Authenticate to GCP (Workload Identity Federation)
2. Deploy code artifacts to GCS
3. Update/restart services as needed

## Authentication
Uses **Workload Identity Federation** (no service account keys stored!) — 
sa-github-actions-fraud-dev service account.
