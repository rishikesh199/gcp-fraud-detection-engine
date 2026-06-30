-- ============================================================
-- File: models/marts/fct_fraud_kpis.sql
-- Purpose: Daily KPI summary for reporting
-- Layer: MART
-- ============================================================

{{
    config(
        materialized='table',
        tags=['daily','mart','kpi']
    )
}}

WITH transactions AS (

    SELECT *

    FROM {{ ref('fct_fraud_transactions') }}

)

SELECT

    transaction_date AS report_date,

    --------------------------------------------------------
    -- Volume Metrics
    --------------------------------------------------------

    COUNT(*) AS total_transactions,

    COUNT(DISTINCT nameOrig_masked) AS unique_customers,

    --------------------------------------------------------
    -- Fraud Breakdown
    --------------------------------------------------------

    SUM(CASE WHEN fraud_band='HIGH' THEN 1 ELSE 0 END)
        AS high_risk_count,

    SUM(CASE WHEN fraud_band='NORMAL' THEN 1 ELSE 0 END)
        AS normal_risk_count,

    --------------------------------------------------------
    -- Amount Metrics
    --------------------------------------------------------

    ROUND(SUM(amount),2)
        AS total_amount,

    ROUND(AVG(amount),2)
        AS avg_amount,

    ROUND(MAX(amount),2)
        AS max_amount,

    --------------------------------------------------------
    -- Fraud Rate
    --------------------------------------------------------

    ROUND(

        SUM(CASE WHEN is_fraud_transaction THEN 1 ELSE 0 END)

        *100.0

        /COUNT(*),

        2

    ) AS fraud_rate_pct,

    --------------------------------------------------------
    -- High Amount Transactions
    --------------------------------------------------------

    SUM(CASE WHEN is_high_amount THEN 1 ELSE 0 END)

        AS high_amount_transactions,

    --------------------------------------------------------
    -- Data Source
    --------------------------------------------------------

    SUM(CASE WHEN data_source='batch_historical' THEN 1 ELSE 0 END)

        AS batch_records

FROM transactions

GROUP BY transaction_date

ORDER BY transaction_date