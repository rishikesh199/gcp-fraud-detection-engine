# Enterprise GCP Fraud Detection Platform

## 📌 Project Overview
A production-grade Lambda Architecture implementation processing millions of synthetic financial transactions. It features real-time streaming (Apache Beam/Dataflow) and bulk batch processing (PySpark/Dataproc), governed by Terraform (IaC), orchestrated by Cloud Composer (Airflow), and transformed using dbt.

## 🌐 End-to-End System Architecture
```mermaid
flowchart TD
    subgraph "Ingestion Layer"
        G["Python Transaction Generator"]
        GCS["GCS: Raw CSV Files"]
    end

    subgraph "Streaming Pipeline (Real-Time)"
        PS(("Cloud Pub/Sub"))
        DF("Cloud Dataflow (Apache Beam)")
        DLQ[("GCS Dead Letter Bucket")]
    end

    subgraph "Batch Pipeline (Historical)"
        DP("Cloud Dataproc (PySpark)")
    end

    subgraph "Data Warehouse & Transformation"
        BQ_RAW[("BigQuery: fraud_raw_dev")]
        DBT("dbt Core")
        BQ_MART[("BigQuery: fraud_marts_dev")]
    end

    subgraph "Orchestration"
        CC("Cloud Composer (Airflow)")
    end

    G -->|"Real-time JSON"| PS
    PS -->|"Subscribes"| DF
    DF -->|"Valid Schema & Masking"| BQ_RAW
    DF -.->|"Malformed Data"| DLQ
    
    GCS -->|"Reads Bulk"| DP
    DP -->|"PySpark + SHA-256"| BQ_RAW
    
    BQ_RAW -->|"Sources"| DBT
    DBT -->|"Tests & Models"| BQ_MART
    
    CC -->|"1. Create Cluster"| DP
    CC -->|"2. Submit PySpark Job"| DP
    CC -->|"3. Trigger"| DBT
    CC -->|"4. Delete Cluster"| DP
```

## 🏗️ Repository Structure
| Directory | Purpose |
|---|---|
| `/infrastructure` | Terraform declarative IaC for all GCP resources. |
| `/data_generator` | Python simulation engine generating 26-column synthetic transactions. |
| `/streaming_pipeline` | Apache Beam pipeline for real-time Pub/Sub ingestion and PII masking. |
| `/batch_pipeline` | PySpark jobs for massive historical CSV processing on Dataproc. |
| `/airflow_dags` | Cloud Composer DAG orchestrating the ephemeral Dataproc cluster pattern. |
| `/dbt_fraud` | SQL models for analytics engineering and data quality testing (`schema.yml`). |

## 🚀 Execution Flow
1. Provision infrastructure: `cd infrastructure && terraform apply`
2. Start streaming: `python data_generator/transaction_generator.py --mode stream`
3. Launch Dataflow: `python streaming_pipeline/fraud_streaming_pipeline.py --runner DataflowRunner`
4. Trigger Batch/dbt: via Airflow UI (`fraud_batch_dag.py`)

*See individual folder READMEs for deep technical details.*
