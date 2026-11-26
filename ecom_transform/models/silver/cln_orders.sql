-- Silver cleaned model for orders
with bronze_orders as (
  select *
  from {{ ref("stg_orders") }}
),

deduplicated_orders as (
  select
    *,
    row_number() over (
      partition by order_id
      order by _ingested_at desc
    ) as row_num
  from bronze_orders
  where order_id is not null and user_id is not null
)

select
  cast(order_id as integer) as order_id,
  cast(user_id as integer) as user_id,
  upper(trim(coalesce(status, 'PENDING'))) as order_status,
  cast(order_date as timestamp) as ordered_at,
  _ingested_at,
  current_timestamp as _transformed_at
from deduplicated_orders
where row_num = 1