-- Silver cleaned model for order line items
with bronze_order_items as (
  select *
  from {{ ref("stg_order_items") }}
),

deduplicated_order_items as (
  select
    *,
    row_number() over (
      partition by order_item_id
      order by _ingested_at desc
    ) as row_num
  from bronze_order_items
  where order_item_id is not null and order_id is not null and product_id is not null
)

select
  cast(order_item_id as integer) as order_item_id,
  cast(order_id as integer) as order_id,
  cast(product_id as integer) as product_id,
  cast(quantity as integer) as quantity,
  cast(coalesce(unit_price, 0.00) as decimal(12, 2)) as unit_price,
  cast(quantity * coalesce(unit_price, 0.00) as decimal(12, 2)) as line_total,
  _ingested_at,
  current_timestamp as _transformed_at
from deduplicated_order_items
where row_num = 1 and quantity > 0 and coalesce(unit_price, 0.00) >= 0