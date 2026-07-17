-- ============================================================
-- Mart Model: fct_fraud_transactions
-- Purpose: Unified fact table combining batch + streaming data
-- Source: stg_transactions (batch) UNION ALL stg_streaming_transactions
-- Materialization: INCREMENTAL
-- ============================================================

{{
  config(
    materialized='incremental',
    partition_by={
      "field": "transaction_date",
      "data_type": "date",
      "granularity": "day"
    },
    cluster_by=["transaction_type", "fraud_band", "data_source"],
    unique_key="transaction_id"
  )
}}

WITH batch_data AS (
    SELECT * FROM {{ ref('stg_transactions') }}
    {% if is_incremental() %}
    WHERE loaded_at >= (SELECT COALESCE(MAX(loaded_at), '1900-01-01') FROM {{ this }} WHERE data_source = 'batch_csv')
    {% endif %}
),

streaming_data AS (
    SELECT * FROM {{ ref('stg_streaming_transactions') }}
    {% if is_incremental() %}
    WHERE loaded_at >= (SELECT COALESCE(MAX(loaded_at), '1900-01-01') FROM {{ this }} WHERE data_source = 'streaming_realtime')
    {% endif %}
),

unified AS (
    SELECT * FROM batch_data
    UNION ALL
    SELECT * FROM streaming_data
)

SELECT
    transaction_id,
    event_timestamp,
    transaction_date,
    customer_id_masked,
    receiver_id_masked,
    card_number_masked,
    transaction_type,
    amount,
    currency,
    merchant_id,
    merchant_name,
    merchant_category,
    country,
    city,
    device_id_masked,
    ip_address_masked,
    payment_channel,
    payment_method,
    fraud_score,
    fraud_band,
    is_fraud,
    is_high_amount,
    action_required,
    data_source,
    processing_timestamp,
    loaded_at,
    FORMAT_DATE('%Y-%m', transaction_date) AS transaction_month
FROM unified