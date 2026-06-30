{{
    config(
        materialized='table',

        partition_by={
            "field":"transaction_date",
            "data_type":"date"
        },

        cluster_by=[
            "transaction_type",
            "fraud_band"
        ],

        tags=["daily","mart"]
    )
}}

WITH transactions AS (

SELECT *

FROM {{ ref('stg_transactions') }}

),

final AS (

SELECT

step,

transaction_type,

amount,

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

loaded_at,

data_source,

----------------------------------------------------
-- Business Columns
----------------------------------------------------

CASE

WHEN isFraud=1

THEN TRUE

ELSE FALSE

END

AS is_fraud_transaction,

CASE

WHEN fraud_band='HIGH'

THEN 'IMMEDIATE_ACTION'

ELSE 'CLEAR'

END

AS action_required,

DATE(processing_timestamp)

AS transaction_date,

FORMAT_TIMESTAMP(

'%Y-%m',

processing_timestamp

)

AS transaction_month

FROM transactions

)

SELECT *

FROM final