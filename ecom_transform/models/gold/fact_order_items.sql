-- Gold Fact model for granular order line items (Star Schema center)
with silver_order_items as (
    select *
    from {{ ref('cln_order_items') }}
),

silver_orders as (
    select
        order_id,
        user_id,
        order_status,
        ordered_at
    from {{ ref('cln_orders') }}
)

select
    oi.order_item_id,
    oi.order_id,
    o.user_id,
    oi.product_id,
    o.order_status,
    o.ordered_at,
    cast(o.ordered_at as date) as order_date,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    case
        when o.order_status = 'COMPLETED' then oi.line_total
        else 0.00
    end as realized_line_revenue,
    current_timestamp as _gold_updated_at
from silver_order_items oi
inner join silver_orders o
    on oi.order_id = o.order_id