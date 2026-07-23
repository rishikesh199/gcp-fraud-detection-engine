-- ============================================================
-- Mart Model: fct_fraud_transactions
-- Purpose: Unified fact table combining batch + streaming data
-- Source: stg_transactions (batch) UNION ALL stg_streaming_transactions
-- Materialization: TABLE
-- Partition: transaction_date (DAY)
-- Cluster: transaction_type, fraud_band, data_source
-- ============================================================

{{
  config(
    materialized='table',
    partition_by={
      "field": "transaction_date",
      "data_type": "date",
      "granularity": "day"
    },
    cluster_by=["transaction_type", "fraud_band", "data_source"]
  )
}}

WITH batch_data AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

streaming_data AS (
    SELECT * FROM {{ ref('stg_streaming_transactions') }}
),

-- UNION ALL: Both sources share identical 26-column schema
unified AS (
    SELECT * FROM batch_data
    UNION ALL
    SELECT * FROM streaming_data
)

SELECT
    -- Identity
    transaction_id,
    event_timestamp,
    transaction_date,

    -- Parties (PII masked)
    customer_id_masked,
    receiver_id_masked,
    card_number_masked,

    -- Transaction details
    transaction_type,
    amount,
    currency,

    -- Merchant
    merchant_id,
    merchant_name,
    merchant_category,

    -- Location
    country,
    city,

    -- Device (PII masked)
    device_id_masked,
    ip_address_masked,

    -- Payment
    payment_channel,
    payment_method,

    -- Fraud intelligence
    fraud_score,
    fraud_band,
    is_fraud,
    is_high_amount,
    action_required,

    -- Metadata
    data_source,
    processing_timestamp,
    loaded_at,

    -- Derived: Month for trend analysis
    FORMAT_DATE('%Y-%m', transaction_date) AS transaction_month
FROM unified
