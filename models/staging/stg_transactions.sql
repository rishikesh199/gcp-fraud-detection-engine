-- ============================================================
-- Staging Model: stg_transactions (Batch)
-- Source: ext_batch_transactions (PySpark → Parquet → BQ External)
-- Output: EXACTLY SAME 29 columns as stg_streaming_transactions
-- Schema MUST match streaming staging for UNION ALL in fact table
-- ============================================================

{{
    config(
        tags=['daily', 'staging']
    )
}}

SELECT
    -- 1-2: Identity
    transaction_id,
    CAST(event_timestamp AS TIMESTAMP) AS event_timestamp,

    -- 3-12: Transaction Details
    transaction_type,
    ROUND(CAST(amount AS FLOAT64), 2) AS amount,
    currency,
    merchant_id,
    TRIM(merchant_name) AS merchant_name,
    UPPER(TRIM(COALESCE(merchant_category, 'UNKNOWN'))) AS merchant_category,
    UPPER(TRIM(COALESCE(country, 'IN'))) AS country,
    TRIM(COALESCE(city, 'UNKNOWN')) AS city,
    payment_channel,
    payment_method,

    -- 13-15: Behavioral Analytics
    CAST(is_vpn_used AS BOOLEAN) AS is_vpn_used,
    CAST(login_to_checkout_sec AS INT64) AS login_to_checkout_sec,
    CAST(bot_behavior_flag AS BOOLEAN) AS bot_behavior_flag,

    -- 16-20: Masked PII
    customer_id_masked,
    receiver_id_masked,
    card_number_masked,
    device_id_masked,
    ip_address_masked,

    -- 21-25: Fraud Analytics
    CAST(fraud_score AS FLOAT64) AS fraud_score,
    fraud_band,
    CAST(is_fraud AS BOOLEAN) AS is_fraud,
    CAST(is_high_amount AS BOOLEAN) AS is_high_amount,
    action_required,

    -- 26-27: Pipeline Metadata
    data_source,
    CAST(processing_timestamp AS TIMESTAMP) AS processing_timestamp,

    -- 28-29: dbt Metadata (SAME as streaming staging)
    DATE(event_timestamp) AS transaction_date,
    CURRENT_TIMESTAMP() AS loaded_at

FROM {{ source('fraud_raw', 'ext_batch_transactions') }}
WHERE transaction_id IS NOT NULL
