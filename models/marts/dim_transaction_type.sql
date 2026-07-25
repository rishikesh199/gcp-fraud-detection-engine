-- ============================================================
-- Mart Model: dim_transaction_type
-- Purpose: Transaction type dimension with fraud analytics
-- Source: fct_fraud_transactions
-- ============================================================

{{
    config(
        materialized='table',
        tags=['daily', 'mart', 'dimension']
    )
}}

WITH fact AS (
    SELECT * FROM {{ ref('fct_fraud_transactions') }}
)

SELECT
    transaction_type,

    -- Volume
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id_masked) AS unique_customers,
    COUNT(DISTINCT transaction_date) AS active_days,

    -- Amount Statistics
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(MAX(amount), 2) AS max_amount,

    -- Fraud Statistics
    COUNTIF(is_fraud) AS fraud_transactions,
    ROUND(
        COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud THEN amount ELSE 0 END), 2) AS fraud_amount,
    ROUND(AVG(fraud_score), 1) AS avg_fraud_score,

    -- Risk Distribution
    COUNTIF(fraud_band = 'CRITICAL') AS critical_count,
    COUNTIF(fraud_band = 'HIGH') AS high_count,
    COUNTIF(action_required = 'BLOCK') AS blocked_count,

    -- VPN/Bot correlation per type
    ROUND(
        COUNTIF(is_vpn_used) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS vpn_usage_pct,
    ROUND(
        COUNTIF(bot_behavior_flag) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS bot_usage_pct,

    -- High Amount
    COUNTIF(is_high_amount) AS high_amount_transactions,

    -- Date Range
    MIN(transaction_date) AS first_transaction_date,
    MAX(transaction_date) AS last_transaction_date,

    -- Metadata
    CURRENT_TIMESTAMP() AS last_refreshed

FROM fact
GROUP BY transaction_type
