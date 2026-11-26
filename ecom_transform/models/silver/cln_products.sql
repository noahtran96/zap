-- Silver cleaned model for products
with bronze_products as (
  select *
  from {{ ref("stg_products") }}
),

deduplicated_products as (
  select
    *,
    row_number() over (
      partition by product_id
      order by _ingested_at desc
    ) as row_num
  from bronze_products
  where product_id is not null
)

select
  cast(product_id as integer) as product_id,
  trim(coalesce(product_name, 'Unnamed Product')) as product_name,
  upper(trim(coalesce(category, 'GENERAL'))) as category,
  cast(coalesce(price, 0.0) as decimal(12, 2)) as unit_price,
  cast(100 as integer) as stock_quantity,
  _ingested_at,
  current_timestamp as _transformed_at
from deduplicated_products
where row_num = 1
  and coalesce(price, 0.00) >= 0