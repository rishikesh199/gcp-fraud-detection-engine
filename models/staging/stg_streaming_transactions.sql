-- ============================================================
-- Staging Model: stg_streaming_transactions (Streaming Path)
-- Source: fraud_raw.raw_streaming_transactions (Dataflow)
-- Schema: Master schema (26 cols, PII already masked by Dataflow)
-- ============================================================

WITH source AS (
    SELECT * FROM {{ source('fraud_raw', 'raw_streaming_transactions') }}
    WHERE transaction_id IS NOT NULL
      AND amount > 0
      AND amount < 5000000
),

cleaned AS (
    SELECT
        transaction_id,
        event_timestamp,
        transaction_date,
        customer_id_masked,
        receiver_id_masked,
        card_number_masked,
        UPPER(TRIM(transaction_type))     AS transaction_type,
        ROUND(amount, 2)                  AS amount,
        UPPER(TRIM(COALESCE(currency, 'INR'))) AS currency,
        merchant_id,
        TRIM(merchant_name)               AS merchant_name,
        UPPER(TRIM(COALESCE(merchant_category, 'UNKNOWN'))) AS merchant_category,
        UPPER(TRIM(COALESCE(country, 'IN'))) AS country,
        TRIM(COALESCE(city, 'UNKNOWN'))   AS city,
        device_id_masked,
        ip_address_masked,
        UPPER(TRIM(COALESCE(payment_channel, 'MOBILE_APP'))) AS payment_channel,
        UPPER(TRIM(COALESCE(payment_method, 'UPI'))) AS payment_method,
        COALESCE(fraud_score, 0)          AS fraud_score,
        UPPER(TRIM(COALESCE(fraud_band, 'LOW'))) AS fraud_band,
        COALESCE(is_fraud, FALSE)         AS is_fraud,
        COALESCE(is_high_amount, FALSE)   AS is_high_amount,
        UPPER(TRIM(COALESCE(action_required, 'CLEAR'))) AS action_required,
        'streaming_realtime'              AS data_source,
        COALESCE(processing_timestamp, CURRENT_TIMESTAMP()) AS processing_timestamp,
        CURRENT_TIMESTAMP()               AS loaded_at
    FROM source
)

SELECT * FROM cleaned
