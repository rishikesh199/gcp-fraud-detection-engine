# Quality Assurance & Testing Suite

## 📌 Enterprise Purpose
This module contains the automated testing suite for the Python-based data pipelines. While `dbt` handles SQL-level data quality, this directory ensures the procedural code (Apache Beam, PySpark, Data Generator) functions correctly in isolation before being deployed to GCP.

## 🧪 Testing Scope
### 1. PySpark UDF Tests
Validates that the distributed SHA-256 masking logic successfully and deterministically anonymizes PII without causing data loss on null inputs.

### 2. Apache Beam DoFn Tests
Uses `TestPipeline` and `assert_that` to verify that the streaming pipeline correctly routes malformed JSON payloads to the Dead Letter Queue (DLQ) rather than crashing the worker.

### 3. Data Generator Unit Tests
Ensures the `Faker` profiles respect the probability distributions configured in `config.py` (e.g., ensuring exactly 5% of generated traffic is tagged as fraudulent).

## 🚀 Execution Instructions
Ensure you are in the root directory and have your virtual environment activated:
```bash
# Run all tests
pytest tests/

# Run specific module tests
pytest tests/test_spark_udfs.py
```
