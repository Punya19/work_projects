create database llll;
use llll;
select * from table1;
select sku,sum(shipped_units) as total_units
from table1
group by sku
order by total_units desc;

-- Which SKU had the highest shipped units and what % of the overall shipped units for all individual warehouse ids
with sku_summary as(
select sku,sum(shipped_units) as total_units
from table1
group by sku
),
ranked_sku as(
select sku,total_units,
round(total_units*100.0/sum(total_units) over(),2) as network_percentage,
row_number() over(order by total_units desc) as rn
from sku_summary
)
select sku,total_units,network_percentage from ranked_sku
where rn<=10;

-- .Which SKU had the highest shipped units and what % of the overall shipped units for all individual warehouse ids
with warehouse_summary as(
select warehouse_id,sku,ship_day,sum(shipped_units) as total_units
from table1
group by warehouse_id,ship_day,sku
),
ranked_warehouse as(
select warehouse_id,sku,total_units,ship_day,
round(total_units*100/sum(total_units) over (partition by ship_day, warehouse_id),2) as warehouse_percentage,
row_number() over(partition by warehouse_id,ship_day order by total_units desc)as rn
from warehouse_summary
)
select ship_day,warehouse_id,sku,total_units,warehouse_percentage from ranked_warehouse
where rn=1
order by warehouse_id,ship_day;


--table called deliveries with columns: delivery_id, partner_id, delivery_date, status (Success/Failed/Delayed),
--region. Write me a query to find — for each region — the delivery partner with the highest failure rate in the last 30 days, but only include partners who had at least 50 deliveries.
with delivery_partner as(
select region,partner_id,count(*) as total_deliveres,
sum(case when status = 'failed' then 1 else 0 end) as failed_delivery
sum(case when status = 'failed' then 1 else 0 end)*1.0/count(*) as failed_rate
from deliveries
where delivery_date >= current_date-interval "30 days"
having count(*)>=50
),
ranked as(
select region,partner_id,total_deliveres,failed_delivery,failed_rate,
row_number() over(partition by region order by failed_rate desc) as rn
from delivery_partner
)
select region,partner_id,total_deliveries,failed_delivery,failed_rate
from ranked
where rn=1;


