-- ============================================================
-- Mart Model: fct_fraud_live_dashboard
-- Purpose: Real-time fraud monitoring for operations dashboard
-- Shows ONLY streaming data (last 24 hours)
-- Materialized as VIEW for real-time freshness
-- ============================================================

{{
    config(
        materialized='view',
        tags=['realtime', 'mart', 'dashboard']
    )
}}

WITH live_data AS (
    SELECT * FROM {{ ref('stg_streaming_transactions') }}
    WHERE data_source = 'streaming_realtime'
)

SELECT
    -- Transaction Identity
    transaction_id,
    event_timestamp,
    transaction_type,

    -- Financial Details
    amount,
    currency,
    merchant_name,
    merchant_category,

    -- Location
    country,
    city,

    -- Channel
    payment_channel,
    payment_method,

    -- Fraud Intelligence
    fraud_score,
    fraud_band,
    is_fraud,
    action_required,

    -- Behavioral Signals
    is_vpn_used,
    bot_behavior_flag,
    login_to_checkout_sec,

    -- Customer (masked)
    customer_id_masked,
    device_id_masked,

    -- Real-time Metrics
    TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), event_timestamp, MINUTE) AS minutes_ago,

    CASE
        WHEN fraud_score >= 75 THEN 'CRITICAL_ALERT'
        WHEN fraud_score >= 50 THEN 'HIGH_ALERT'
        WHEN fraud_score >= 25 THEN 'MEDIUM_ALERT'
        ELSE 'NORMAL'
    END AS alert_level,

    CASE
        WHEN is_vpn_used AND bot_behavior_flag AND fraud_score >= 75
            THEN 'VPN + BOT + HIGH SCORE - IMMEDIATE BLOCK'
        WHEN is_vpn_used AND fraud_score >= 50
            THEN 'VPN DETECTED - REVIEW REQUIRED'
        WHEN bot_behavior_flag AND fraud_score >= 50
            THEN 'BOT BEHAVIOR - REVIEW REQUIRED'
        WHEN login_to_checkout_sec < 10 AND amount > 50000
            THEN 'FAST CHECKOUT HIGH VALUE - SUSPICIOUS'
        WHEN country != 'IN' AND fraud_score >= 25
            THEN 'INTERNATIONAL HIGH RISK'
        ELSE 'STANDARD MONITORING'
    END AS alert_description,

    CASE WHEN country != 'IN' THEN TRUE ELSE FALSE END AS is_international,
    CASE WHEN login_to_checkout_sec < 10 THEN TRUE ELSE FALSE END AS is_suspicious_checkout,
    transaction_date,
    loaded_at

FROM live_data
