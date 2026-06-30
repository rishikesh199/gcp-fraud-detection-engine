-- ============================================================
-- File: models/staging/stg_transactions.sql
-- Purpose: Clean and standardize raw transaction data
-- Layer: STAGING
-- Materialization: VIEW
-- ============================================================

{{
    config(
        tags=['daily', 'staging']
    )
}}

WITH source_data AS (

    SELECT *

    FROM {{ source('fraud_raw', 'ext_batch_transactions') }}

    WHERE amount > 0
      AND amount < 10000000

)

SELECT

    step,

    type AS transaction_type,

    ROUND(amount,2) AS amount,

    oldbalanceOrg,

    newbalanceOrig,

    oldbalanceDest,

    newbalanceDest,

    nameOrig_masked,

    nameDest_masked,

    isFraud,

    isFlaggedFraud,

    amount_category,

    is_high_amount,

    balance_change,

    fraud_band,

    processing_timestamp,

    source_file,

    CURRENT_TIMESTAMP() AS loaded_at,

    'batch_historical' AS data_source

FROM source_data