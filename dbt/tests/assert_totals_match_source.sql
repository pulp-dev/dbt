{% for model in [
    'mart_daily_state_metrics', 'mart_fraud_by_category',
    'mart_fraud_by_state', 'mart_customer_risk_profile',
    'mart_hourly_fraud_pattern', 'mart_merchant_analytics'
] %}
select '{{ model }}' as model_name
from {{ ref(model) }}
having
    sum(transaction_count) != (select count() from {{ source('raw', 'transactions') }})
    or sum(total_amount) != (
        select sum(cast(src.amount as Decimal(18, 2)))
        from {{ source('raw', 'transactions') }} as src
    )
{% if not loop.last %}union all{% endif %}
{% endfor %}
