-- TASK D

--Question 1

create or replace procedure sp_apply_category_discount(p_category text, p_percent numeric)
language plpgsql
as $$
begin
  if p_percent < 0 or p_percent >= 100 then
    raise exception 'Percent must be between 0 and 100 (got %)', p_percent;
  end if;
  update products
  set unit_price = unit_price * (1 - (p_percent / 100.0))
  where active = true
    and category = p_category
    and unit_price * (1 - (p_percent / 100.0)) > 0;  -- prevents negative or zero values
end;
$$;

-- ============================================================================================================

--Question 2

create or replace procedure sp_cancel_order(p_order_id int)
language plpgsql
as $$
declare
  v_status varchar(20);
begin
  select status into v_status
  from orders
  where order_id = p_order_id;

  if v_status is null then
    raise exception 'Order % not found', p_order_id; --check for order is available
  end if;

  if v_status = 'delivered' then
    raise notice 'Order % is delivered; not cancelling', p_order_id; 
    return;
  end if;

  if v_status <> 'cancelled' then
    update orders
    set status = 'cancelled'  -- cancelled
    where order_id = p_order_id;

    delete from payments                                         
    where order_id = p_order_id;                                 
  end if;
end;
$$;

-- ============================================================================================================

--Question 3

create or replace procedure sp_reprice_stale_products(p_days int, p_increase numeric)
language plpgsql
as $$
begin
  update products p
  set unit_price = p.unit_price * (1 + (p_increase / 100.0))
  where not exists ( 
    select 1
    from order_items oi
    join orders o on o.order_id = oi.order_id
    where oi.product_id = p.product_id
      and o.order_date >= current_date - (p_days || ' days')::interval
  );
end;
$$;