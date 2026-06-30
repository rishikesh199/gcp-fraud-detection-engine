-- ============================================================
-- File: models/marts/dim_transaction_type.sql
-- Purpose: Transaction Type Dimension
-- Layer: MART
-- Materialization: TABLE
-- ============================================================

{{
    config(
        materialized='table',
        tags=['daily', 'mart', 'dimension']
    )
}}

WITH transactions AS (

    SELECT *
    FROM {{ ref('fct_fraud_transactions') }}

)

SELECT

    transaction_type,

    ----------------------------------------------------------
    -- Transaction Volume
    ----------------------------------------------------------

    COUNT(*) AS total_transactions,

    COUNT(DISTINCT nameOrig_masked) AS unique_customers,

    COUNT(DISTINCT transaction_date) AS active_days,

    ----------------------------------------------------------
    -- Amount Statistics
    ----------------------------------------------------------

    ROUND(SUM(amount),2) AS total_amount,

    ROUND(AVG(amount),2) AS avg_amount,

    ROUND(MAX(amount),2) AS max_amount,

    ----------------------------------------------------------
    -- Fraud Statistics
    ----------------------------------------------------------

    SUM(CASE
            WHEN is_fraud_transaction THEN 1
            ELSE 0
        END) AS fraud_transactions,

    ROUND(

        SUM(CASE
                WHEN is_fraud_transaction THEN 1
                ELSE 0
            END)
        *100.0
        /COUNT(*),

        2

    ) AS fraud_rate_pct,

    ----------------------------------------------------------
    -- High Amount Transactions
    ----------------------------------------------------------

    SUM(CASE
            WHEN is_high_amount THEN 1
            ELSE 0
        END) AS high_amount_transactions,

    ----------------------------------------------------------
    -- Date Range
    ----------------------------------------------------------

    MIN(transaction_date) AS first_transaction_date,

    MAX(transaction_date) AS last_transaction_date,

    ----------------------------------------------------------
    -- Metadata
    ----------------------------------------------------------

    CURRENT_TIMESTAMP() AS last_refreshed

FROM transactions

GROUP BY transaction_type

ORDER BY fraud_rate_pct DESC