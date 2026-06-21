# ⚡ Data Generator — Synthetic Transaction Generator

This directory contains the Python script that generates **synthetic credit card transactions** for both batch and streaming pipelines.

## What's Inside
- `generate_transactions.py` — Main generator script
- `publish_to_pubsub.py` — Publishes generated transactions to Pub/Sub (streaming)
- `generate_batch_csv.py` — Generates CSV files for batch processing
- `config.py` — Configuration settings (fraud ratio, categories, etc.)

## Features
- Realistic transaction patterns (amounts, merchants, locations)
- Configurable fraud ratio (default: 3-5%)
- Supports both batch (CSV) and streaming (Pub/Sub) modes
- PII data included (for DLP masking demonstration)

## Usage (from Cloud Shell)
```bash
# Generate batch CSV
python data_generator/generate_batch_csv.py --rows 100000

# Stream to Pub/Sub (1-10 events/sec)
python data_generator/publish_to_pubsub.py --rate 10
```
