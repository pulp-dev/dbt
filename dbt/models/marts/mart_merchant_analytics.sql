with metrics as (
    select
        merchant,
        count() as transaction_count,
        sum(is_fraud) as fraud_count,
        100.0 * sum(is_fraud) / count() as fraud_rate,
        sum(amount) as total_amount,
        sumIf(amount, is_fraud = 1) as fraud_amount,
        uniqExact(customer_id) as unique_customers
    from {{ ref('stg_transactions') }}
    group by merchant
)

select
    *,
    fraud_rate >= 1 and fraud_count >= 5 as is_suspicious
from metrics
