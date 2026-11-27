-- Gold dimension model for users
with silver_users as (
  select *
  from {{ ref('cln_users') }}
)

select
  user_id,
  full_name,
  email,
  country,
  created_at as registered_at,
  date_trunc('day', created_at) as registered_date,
  current_timestamp as _gold_updated_at
from silver_users