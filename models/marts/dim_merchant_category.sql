-- ============================================================
-- Mart Model: dim_merchant_category
-- Purpose: Merchant category dimension with risk analysis
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
    merchant_category,

    -- Volume
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT merchant_id) AS unique_merchants,
    COUNT(DISTINCT customer_id_masked) AS unique_customers,

    -- Amount
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(MAX(amount), 2) AS max_amount,

    -- Fraud analysis
    COUNTIF(is_fraud) AS fraud_transactions,
    ROUND(
        COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud THEN amount ELSE 0 END), 2) AS fraud_amount,
    ROUND(AVG(fraud_score), 1) AS avg_fraud_score,

    -- Risk distribution
    COUNTIF(fraud_band = 'CRITICAL') AS critical_count,
    COUNTIF(fraud_band = 'HIGH') AS high_count,
    COUNTIF(action_required = 'BLOCK') AS blocked_count,

    -- VPN/Bot per category
    ROUND(
        COUNTIF(is_vpn_used) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS vpn_usage_pct,
    ROUND(
        COUNTIF(bot_behavior_flag) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS bot_usage_pct,

    -- Category risk level (derived)
    CASE
        WHEN COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0) > 15 THEN 'VERY_HIGH_RISK'
        WHEN COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0) > 10 THEN 'HIGH_RISK'
        WHEN COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0) > 5  THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END AS risk_level,

    CURRENT_TIMESTAMP() AS last_refreshed

FROM fact
GROUP BY merchant_category
