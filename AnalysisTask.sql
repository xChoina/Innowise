with fil_users as(
	select id, name
	from users
	where registration_phone = 79991112233
),
 log_data as(
	select user_id, count(*) as log_count
	from logs l 
	inner join fil_users f on l.user_id = f.id
	where log_date >= '2026-01-01' and log_date < '2027-01-01'
	group by user_id
),
amount_data as(
	select user_id, amount
	from orders o
	inner join fil_users f on o.user_id = f.id
	where order_date >= '2026-01-01' and order_date < '2027-01-01' and amount > 500
	
) 
select f.id, f.name, coalesce(l.log_count, 0) as log_count, a.amount
from fil_users f
left join log_data l on f.id = l.user_id
inner join amount_data a on f.id = a.user_id
union all
select id, name, 0 as log_count, 0 as amount
from users
where status='DELETED'
order by log_count desc

 