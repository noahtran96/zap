-- Silver cleaned model for users
with bronze_users as (
  select *
  from {{ ref("stg_users")}}
),

deduplicated_users as (
  select
    *,
    row_number() over (
      partition by user_id
      order by _ingested_at desc
    ) as row_num
  from bronze_users
  where user_id is not null
)

select
  cast(user_id as integer) as user_id,
  trim(coalesce(name, 'unknown')) as full_name,
  lower(trim(email)) as email,
  trim(coalesce(country, 'Unknown')) as country,
  cast(created_at as timestamp) as created_at,
  _ingested_at,
  current_timestamp as _transformed_at
from deduplicated_users
where row_num = 1