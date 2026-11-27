-- Gold dimension model for products
with silver_products as (
  select *
  from {{ ref('cln_products') }}
)

select
  product_id,
  product_name,
  category,
  unit_price,
  stock_quantity,
  case
    when unit_price >= 300 then 'PREMIUM'
    when unit_price >= 100 then 'MID_RANGE'
    else 'BUDGET'
  end as price_tier,
  current_timestamp as _gold_updated_at
from silver_products