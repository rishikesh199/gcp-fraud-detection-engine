-- ============================================================
-- Mart Model: dim_geography
-- Purpose: Geographic dimension with fraud hotspot analysis
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
    country,
    city,

    -- Volume
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id_masked) AS unique_customers,

    -- Amount
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,

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

    -- Top transaction types in this location
    COUNT(DISTINCT transaction_type) AS unique_transaction_types,

    -- VPN usage by geography
    ROUND(
        COUNTIF(is_vpn_used) * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS vpn_usage_pct,

    -- International flag
    CASE WHEN country != 'IN' THEN TRUE ELSE FALSE END AS is_international,

    -- Location risk level
    CASE
        WHEN COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0) > 20 THEN 'FRAUD_HOTSPOT'
        WHEN COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0) > 10 THEN 'HIGH_RISK'
        WHEN COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0) > 5  THEN 'ELEVATED'
        ELSE 'NORMAL'
    END AS location_risk_level,

    CURRENT_TIMESTAMP() AS last_refreshed

FROM fact
GROUP BY country, city
