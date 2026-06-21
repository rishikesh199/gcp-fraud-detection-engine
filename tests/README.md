# 🧪 Tests — Quality Assurance

This directory contains test scripts for validating pipeline components.

## What's Inside
- `test_data_generator.py` — Unit tests for data generator
- `test_streaming_pipeline.py` — Unit tests for Beam transforms
- `test_pyspark_jobs.py` — Unit tests for PySpark ETL logic
- `test_bigquery_schemas.py` — Schema validation tests
- `integration/` — Integration test scripts
- `conftest.py` — Pytest fixtures and shared setup

## Running Tests (from Cloud Shell)
```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test file
python -m pytest tests/test_data_generator.py -v
```

## Test Coverage Goals
- Unit tests: 80%+ code coverage
- Integration tests: Key pipeline flows
- Data quality: dbt tests (in dbt_fraud/ directory)
