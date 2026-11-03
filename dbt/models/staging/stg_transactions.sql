with normalized as (
    select
        cast(transaction_time as DateTime) as transaction_time,
        trimBoth(cast(merch as String)) as merchant,
        lower(trimBoth(cast(cat_id as String))) as category,
        cast(amount as Decimal(18, 2)) as amount,
        lower(hex(MD5(toJSONString(tuple(
            lower(trimBoth(name_1)), lower(trimBoth(name_2)),
            lower(trimBoth(street)), post_code
        ))))) as customer_id,
        upper(trimBoth(cast(gender as String))) as gender,
        upper(trimBoth(cast(us_state as String))) as us_state,
        cast(lat as Float64) as latitude,
        cast(lon as Float64) as longitude,
        cast(merchant_lat as Float64) as merchant_latitude,
        cast(merchant_lon as Float64) as merchant_longitude,
        cast(target as UInt8) as is_fraud
    from {{ source('raw', 'transactions') }}
)

select
    *,
    toDate(transaction_time) as transaction_date,
    toHour(transaction_time) as transaction_hour,
    {{ dbt_date.day_of_week('transaction_time', isoweek=true) }} as day_of_week,
    {{ amount_bucket('amount') }} as amount_bucket
from normalized
