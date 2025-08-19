-- TASK C

--Question 1

create or replace function fn_customer_lifetime_value(p_customer_id int)
returns numeric
language plpgsql
as $$
declare
  v_total numeric := 0;  -- running total
begin
  select coalesce(sum(p.amount), 0)
  into v_total
  from orders o
  join payments p on p.order_id = o.order_id
  where o.customer_id = p_customer_id
    and o.status <> 'cancelled';  -- exclude cancelled

  return v_total;
end;
$$;

-- ============================================================================================================

--Question 2

create or replace function recent_orders(p_days int)
returns table(
  order_id     int,
  customer_id  int,
  order_date   timestamp,
  status       varchar,
  order_total  numeric
)
language plpgsql
as $$
begin
  return query
  select
    o.order_id,                               
    o.customer_id,                            
    o.order_date,                             
    o.status,                                 
    coalesce(                                 
      (select sum(oi.quantity * oi.unit_price)
       from order_items oi
       where oi.order_id = o.order_id), 0
    ) as order_total
  from orders o
  where o.order_date >= current_date - (p_days || ' days')::interval  -- last p_days
  order by o.order_date desc;  -- sort function
end;
$$;

-- SELECT * FROM recent_orders(30) ORDER BY order_date DESC;

-- ============================================================================================================

--Question 3

create or replace function fn_title_case_city(p_text text)
returns text
language plpgsql
as $$
begin
  return initcap(trim(lower(p_text))); 
end;
$$;