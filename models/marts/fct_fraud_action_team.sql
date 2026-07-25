-- ============================================================
-- Mart Model: fct_fraud_action_team
-- Purpose: Investigation queue for fraud operations team
-- Contains ONLY transactions requiring REVIEW or BLOCK
-- Each row = 1 case for an analyst to investigate
-- ============================================================

{{
    config(
        materialized='table',
        tags=['daily', 'mart', 'operations']
    )
}}

WITH flagged AS (
    SELECT *
    FROM {{ ref('fct_fraud_transactions') }}
    WHERE action_required IN ('REVIEW', 'BLOCK')
)

SELECT
    -- Case Identity
    transaction_id,
    event_timestamp,
    transaction_date,

    -- Priority & Action
    action_required,
    fraud_score,
    fraud_band,

    -- Case Priority (for sorting in dashboard)
    CASE
        WHEN action_required = 'BLOCK' AND fraud_score >= 90 THEN 1
        WHEN action_required = 'BLOCK' THEN 2
        WHEN action_required = 'REVIEW' AND fraud_score >= 60 THEN 3
        ELSE 4
    END AS priority_rank,

    -- Financial Context
    transaction_type,
    amount,
    currency,
    amount_category,

    -- Merchant Context
    merchant_name,
    merchant_category,

    -- Location Context
    country,
    city,
    is_international,

    -- Customer & Device (masked for compliance)
    customer_id_masked,
    receiver_id_masked,
    device_id_masked,
    ip_address_masked,

    -- Channel Context
    payment_channel,
    payment_method,

    -- Risk Signals (WHY this was flagged)
    is_vpn_used,
    bot_behavior_flag,
    login_to_checkout_sec,
    is_suspicious_checkout,
    risk_category,

    -- Investigation Reason (human-readable)
    CASE
        WHEN is_vpn_used AND bot_behavior_flag
            THEN 'VPN + Bot Behavior Detected - Automated Attack Suspected'
        WHEN is_vpn_used AND is_international
            THEN 'VPN + International Transaction - Identity Masking Suspected'
        WHEN bot_behavior_flag AND is_suspicious_checkout
            THEN 'Bot + Fast Checkout - Credential Stuffing Suspected'
        WHEN is_vpn_used
            THEN 'VPN Detected - Location Spoofing Risk'
        WHEN bot_behavior_flag
            THEN 'Bot Behavior Detected - Automated Fraud Risk'
        WHEN is_suspicious_checkout AND amount > 50000
            THEN 'Abnormally Fast High-Value Checkout'
        WHEN is_international AND amount > 100000
            THEN 'High-Value International Wire'
        WHEN amount > 200000
            THEN 'Very High Value Transaction'
        ELSE 'Multi-Factor Risk Score Threshold Exceeded'
    END AS investigation_reason,

    -- SLA Tracking
    CASE
        WHEN action_required = 'BLOCK' THEN 'Within 15 Minutes'
        WHEN fraud_score >= 70 THEN 'Within 1 Hour'
        ELSE 'Within 4 Hours'
    END AS resolution_sla,

    -- Pipeline Metadata
    data_source,
    processing_timestamp,
    CURRENT_TIMESTAMP() AS case_created_at

FROM flagged
