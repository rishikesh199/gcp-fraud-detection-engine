-- ============================================================
-- Staging Model: stg_streaming_transactions
-- Source: raw_streaming_transactions (Dataflow → BQ)
-- Output: 29 columns (27 raw + transaction_date + loaded_at)
-- ============================================================

{{
    config(
        tags=['streaming', 'staging']
    )
}}

SELECT
    -- 1-2: Identity
    transaction_id,
    event_timestamp,

    -- 3-12: Transaction Details
    transaction_type,
    ROUND(amount, 2) AS amount,
    currency,
    merchant_id,
    TRIM(merchant_name) AS merchant_name,
    UPPER(TRIM(COALESCE(merchant_category, 'UNKNOWN'))) AS merchant_category,
    UPPER(TRIM(COALESCE(country, 'IN'))) AS country,
    TRIM(COALESCE(city, 'UNKNOWN')) AS city,
    payment_channel,
    payment_method,

    -- 13-15: Behavioral Analytics
    is_vpn_used,
    login_to_checkout_sec,
    bot_behavior_flag,

    -- 16-20: Masked PII
    customer_id_masked,
    receiver_id_masked,
    card_number_masked,
    device_id_masked,
    ip_address_masked,

    -- 21-25: Fraud Analytics (Computed by Dataflow)
    fraud_score,
    fraud_band,
    is_fraud,
    is_high_amount,
    action_required,

    -- 26-27: Pipeline Metadata
    data_source,
    processing_timestamp,

    -- 28-29: dbt Metadata (added by dbt)
    DATE(event_timestamp) AS transaction_date,
    CURRENT_TIMESTAMP() AS loaded_at

FROM {{ source('fraud_raw', 'raw_streaming_transactions') }}
WHERE transaction_id IS NOT NULL
