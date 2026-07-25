-- ============================================================
-- Mart Model: fct_fraud_kpis (JP Morgan Level Daily KPIs)
-- Purpose: Executive-level daily fraud analytics dashboard
-- Source: fct_fraud_transactions
-- ============================================================

{{
    config(
        materialized='table',
        tags=['daily', 'mart', 'kpi']
    )
}}

WITH transactions AS (
    SELECT * FROM {{ ref('fct_fraud_transactions') }}
)

SELECT
    transaction_date AS report_date,

    -- ===== VOLUME METRICS =====
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id_masked) AS unique_customers,
    COUNT(DISTINCT merchant_id) AS unique_merchants,
    COUNT(DISTINCT transaction_type) AS unique_transaction_types,

    -- ===== AMOUNT METRICS =====
    ROUND(SUM(amount), 2) AS total_volume,
    ROUND(AVG(amount), 2) AS avg_transaction_amount,
    ROUND(MAX(amount), 2) AS max_transaction_amount,
    ROUND(MIN(amount), 2) AS min_transaction_amount,
    ROUND(APPROX_QUANTILES(amount, 100)[OFFSET(50)], 2) AS median_amount,
    ROUND(APPROX_QUANTILES(amount, 100)[OFFSET(90)], 2) AS p90_amount,
    ROUND(APPROX_QUANTILES(amount, 100)[OFFSET(99)], 2) AS p99_amount,

    -- ===== FRAUD METRICS (Core) =====
    COUNTIF(is_fraud) AS fraud_count,
    ROUND(
        COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0), 4
    ) AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN is_fraud THEN amount ELSE 0 END), 2) AS total_fraud_amount,
    ROUND(AVG(fraud_score), 2) AS avg_fraud_score,
    ROUND(MAX(fraud_score), 2) AS max_fraud_score,

    -- ===== FRAUD BAND DISTRIBUTION =====
    COUNTIF(fraud_band = 'LOW') AS low_risk_count,
    COUNTIF(fraud_band = 'MEDIUM') AS medium_risk_count,
    COUNTIF(fraud_band = 'HIGH') AS high_risk_count,
    COUNTIF(fraud_band = 'CRITICAL') AS critical_risk_count,

    -- ===== ACTION DISTRIBUTION =====
    COUNTIF(action_required = 'CLEAR') AS action_clear_count,
    COUNTIF(action_required = 'MONITOR') AS action_monitor_count,
    COUNTIF(action_required = 'REVIEW') AS action_review_count,
    COUNTIF(action_required = 'BLOCK') AS action_block_count,

    -- ===== VPN FRAUD CORRELATION =====
    COUNTIF(is_vpn_used) AS vpn_transactions,
    ROUND(
        COUNTIF(is_vpn_used AND is_fraud) * 100.0
        / NULLIF(COUNTIF(is_vpn_used), 0), 2
    ) AS vpn_fraud_rate_pct,

    -- ===== BOT BEHAVIOR ANALYSIS =====
    COUNTIF(bot_behavior_flag) AS bot_transactions,
    ROUND(
        COUNTIF(bot_behavior_flag AND is_fraud) * 100.0
        / NULLIF(COUNTIF(bot_behavior_flag), 0), 2
    ) AS bot_fraud_rate_pct,

    -- ===== CHANNEL DISTRIBUTION =====
    COUNTIF(payment_channel = 'MOBILE_APP') AS mobile_app_count,
    COUNTIF(payment_channel = 'WEB') AS web_count,
    COUNTIF(payment_channel = 'POS_TERMINAL') AS pos_terminal_count,

    -- ===== INTERNATIONAL FRAUD =====
    COUNTIF(is_international) AS international_count,
    ROUND(
        COUNTIF(is_international AND is_fraud) * 100.0
        / NULLIF(COUNTIF(is_international), 0), 2
    ) AS international_fraud_rate_pct,

    -- ===== HIGH AMOUNT TRANSACTIONS =====
    COUNTIF(is_high_amount) AS high_amount_count,
    ROUND(
        SUM(CASE WHEN is_high_amount THEN amount ELSE 0 END), 2
    ) AS high_amount_total,

    -- ===== SUSPICIOUS CHECKOUT =====
    COUNTIF(is_suspicious_checkout) AS suspicious_checkout_count,
    ROUND(
        COUNTIF(is_suspicious_checkout AND is_fraud) * 100.0
        / NULLIF(COUNTIF(is_suspicious_checkout), 0), 2
    ) AS suspicious_checkout_fraud_rate_pct,

    -- ===== AMOUNT CATEGORY DISTRIBUTION =====
    COUNTIF(amount_category = 'MICRO') AS micro_txn_count,
    COUNTIF(amount_category = 'SMALL') AS small_txn_count,
    COUNTIF(amount_category = 'MEDIUM') AS medium_txn_count,
    COUNTIF(amount_category = 'LARGE') AS large_txn_count,
    COUNTIF(amount_category = 'VERY_LARGE') AS very_large_txn_count,

    -- ===== DATA SOURCE SPLIT =====
    COUNTIF(data_source = 'streaming_realtime') AS streaming_records,
    COUNTIF(data_source = 'batch_historical') AS batch_records,

    -- ===== RISK CATEGORY DISTRIBUTION =====
    COUNTIF(risk_category = 'EXTREMELY_HIGH') AS extremely_high_risk_count,
    COUNTIF(risk_category = 'VERY_HIGH') AS very_high_risk_count,

    -- ===== METADATA =====
    CURRENT_TIMESTAMP() AS last_refreshed

FROM transactions
GROUP BY transaction_date
