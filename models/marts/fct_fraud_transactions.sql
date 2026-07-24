-- ============================================================
-- Mart Model: fct_fraud_transactions (34 columns)
-- Purpose: Master fact table - UNION ALL of batch + streaming
-- Adds 5 derived analytics columns on top of 29 staging columns
-- Partitioned by transaction_date, clustered by fraud_band
-- ============================================================

{{
    config(
        materialized='table',
        partition_by={
            "field": "transaction_date",
            "data_type": "date"
        },
        cluster_by=["transaction_type", "fraud_band"],
        tags=['daily', 'mart', 'fact']
    )
}}

WITH batch AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

streaming AS (
    SELECT * FROM {{ ref('stg_streaming_transactions') }}
),

combined AS (
    SELECT * FROM batch
    UNION ALL
    SELECT * FROM streaming
),

-- Dedup across batch and streaming (same txn may exist in both)
deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id
            ORDER BY processing_timestamp DESC
        ) AS _row_num
    FROM combined
)

SELECT
    -- 1-29: All staging columns
    transaction_id,
    event_timestamp,
    transaction_type,
    amount,
    currency,
    merchant_id,
    merchant_name,
    merchant_category,
    country,
    city,
    payment_channel,
    payment_method,
    is_vpn_used,
    login_to_checkout_sec,
    bot_behavior_flag,
    customer_id_masked,
    receiver_id_masked,
    card_number_masked,
    device_id_masked,
    ip_address_masked,
    fraud_score,
    fraud_band,
    is_fraud,
    is_high_amount,
    action_required,
    data_source,
    processing_timestamp,
    transaction_date,
    loaded_at,

    -- 30-34: Derived Analytics (computed by dbt)
    FORMAT_TIMESTAMP('%Y-%m', event_timestamp) AS transaction_month,

    CASE
        WHEN amount < 500 THEN 'MICRO'
        WHEN amount < 5000 THEN 'SMALL'
        WHEN amount < 50000 THEN 'MEDIUM'
        WHEN amount < 100000 THEN 'LARGE'
        ELSE 'VERY_LARGE'
    END AS amount_category,

    CASE
        WHEN is_vpn_used AND bot_behavior_flag THEN 'EXTREMELY_HIGH'
        WHEN is_vpn_used OR bot_behavior_flag THEN 'VERY_HIGH'
        WHEN country != 'IN' THEN 'HIGH'
        WHEN login_to_checkout_sec < 10 THEN 'ELEVATED'
        ELSE 'STANDARD'
    END AS risk_category,

    CASE WHEN country != 'IN' THEN TRUE ELSE FALSE END AS is_international,

    CASE WHEN login_to_checkout_sec < 10 THEN TRUE ELSE FALSE END AS is_suspicious_checkout

FROM deduped
WHERE _row_num = 1
