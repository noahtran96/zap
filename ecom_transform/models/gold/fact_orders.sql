-- Gold fact model for order headers with aggregated order metrics
with silver_orders as (
  select *
  from {{ ref('cln_orders') }}
),

order_item_aggregates as (
  select
    order_id,
    count(order_item_id) as total_line_items,
    sum(quantity) as total_units,
    cast(sum(line_total) as decimal(12, 2)) as order_total_amount
  from {{ ref('cln_order_items') }}
  group by order_id
)

select
  o.order_id,
  o.user_id,
  o.order_status,
  o.ordered_at,
  cast(o.ordered_at as date) as order_date,
  extract(year from o.ordered_at) as order_year,
  extract(month from o.ordered_at) as order_month,
  extract(day from o.ordered_at) as order_day,
  extract(hour from o.ordered_at) as order_hour,
  coalesce(agg.total_line_items, 0) as total_line_items,
  coalesce(agg.total_units, 0) as total_units,
  coalesce(agg.order_total_amount, 0.00) as order_total_amount,
  case
    when o.order_status = 'COMPLETED' then coalesce(agg.order_total_amount, 0.00)
    else 0.00
  end as realized_revenue,
  current_timestamp as _gold_updated_at
FROM silver_orders o
LEFT JOIN order_item_aggregates agg
ON o.order_id = agg.order_id