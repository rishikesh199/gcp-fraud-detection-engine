-- ============================================================
-- Mart Model: fct_fraud_kpis
-- Purpose: Daily KPI summary aggregated from unified fact table
-- Source: fct_fraud_transactions (batch + streaming combined)
-- ============================================================

{{
  config(
    materialized='table',
    partition_by={
      "field": "report_date",
      "data_type": "date",
      "granularity": "day"
    }
  )
}}

WITH fact AS (
    SELECT * FROM {{ ref('fct_fraud_transactions') }}
)

SELECT
    transaction_date                                      AS report_date,

    -- Volume metrics
    COUNT(*)                                              AS total_transactions,
    COUNT(DISTINCT customer_id_masked)                    AS unique_customers,
    COUNT(DISTINCT merchant_id)                           AS unique_merchants,

    -- Fraud metrics
    COUNTIF(is_fraud)                                     AS fraud_transactions,
    ROUND(COUNTIF(is_fraud) * 100.0 / NULLIF(COUNT(*), 0), 2) AS fraud_rate_pct,

    -- Fraud band distribution
    COUNTIF(fraud_band = 'LOW')                           AS low_risk_count,
    COUNTIF(fraud_band = 'MEDIUM')                        AS medium_risk_count,
    COUNTIF(fraud_band = 'HIGH')                          AS high_risk_count,
    COUNTIF(fraud_band = 'CRITICAL')                      AS critical_risk_count,

    -- Amount metrics
    ROUND(SUM(amount), 2)                                 AS total_amount,
    ROUND(AVG(amount), 2)                                 AS avg_amount,
    ROUND(MAX(amount), 2)                                 AS max_amount,
    ROUND(MIN(amount), 2)                                 AS min_amount,
    ROUND(SUM(CASE WHEN is_fraud THEN amount ELSE 0 END), 2) AS fraud_amount,

    -- High amount transactions
    COUNTIF(is_high_amount)                               AS high_amount_count,

    -- Action distribution
    COUNTIF(action_required = 'BLOCK')                    AS blocked_count,
    COUNTIF(action_required = 'REVIEW')                   AS review_count,

    -- Data source breakdown
    COUNTIF(data_source = 'batch_csv')                    AS batch_records,
    COUNTIF(data_source = 'streaming_realtime')           AS streaming_records,

    -- Payment insights
    COUNT(DISTINCT transaction_type)                      AS unique_transaction_types,
    COUNT(DISTINCT country)                               AS unique_countries,

    CURRENT_TIMESTAMP()                                   AS last_refreshed

FROM fact
GROUP BY transaction_date
