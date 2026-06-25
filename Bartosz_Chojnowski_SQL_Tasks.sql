
select category.name , count(film_id) as films
from film_category left join category on film_category.category_id = category.category_id
group by category.name
order by films desc;

select a.first_name, a.last_name, count(r.rental_id ) as rental_count
from  film_actor fa
left join actor a on fa.actor_id = a.actor_id
left join inventory i on fa.film_id = i.film_id
left join rental r on i.inventory_id = r.inventory_id
group by a.actor_id, a.first_name , a.last_name 
order by rental_count desc
limit 10;

select c.name , sum(p.amount) as sum_of_amount  
from category c 
 left join film_category fc on c.category_id = fc.category_id
 left join inventory i on fc.film_id = i.film_id 
 left join rental r on i.inventory_id = r.inventory_id 
 left join payment p on r.rental_id = p.rental_id 
 group by c.category_id , c.name
 order by sum_of_amount  desc;

select f.title
from film f 
except
select f.title
from inventory i 
left join film f on i.film_id = f.film_id;

with children_films as(
	select a.first_name , a.last_name , count(fc.film_id) as number_of_app, 
	dense_rank() over (order by count(fc.film_id) desc) as ranking
	from actor a 
	left join film_actor fa on a.actor_id = fa.actor_id
	left join film_category fc on fa.film_id = fc.film_id
	left join category c on fc.category_id = c.category_id
	where c.name = 'Children'
	group by a.actor_id , a.first_name , a.last_name 
	order by number_of_app desc
)
select first_name, last_name, number_of_app
from children_films
where ranking <=3;

select c2.city,
count(case when c.active = 1 then 1 end) as active_customers,
count(case when c.active = 0 then 1 end) as inactive_customers
from customer c 
left join address a on c.address_id = a.address_id
left join city c2  on a.city_id = c2.city_id
group by c2.city_id , c2.city 
order by inactive_customers desc;

with categories_by_city_hours as(
	select c.name , c3.city , round(sum(extract(epoch from (r.return_date-r.rental_date))/3600),0) as total_hours
	from category c 
	left join film_category fc on c.category_id = fc.category_id
	left join inventory i on fc.film_id = i.film_id 
	left join rental r on i.inventory_id = r.inventory_id
	left join customer c2  on r.customer_id = c2.customer_id
	left join address a on c2.address_id = a.address_id
	left join city c3  on a.city_id = c3.city_id
	group by c.category_id, c.name, c3.city
),
cities_rank as(
	select name, city, total_hours,
	row_number() over( partition by name order by total_hours desc) as ranking
	from categories_by_city_hours
	where city like 'A%'
	union all
	select name, city, total_hours,
	row_number() over( partition by name order by total_hours desc) as ranking
	from categories_by_city_hours
	where city like '%-%'
)
select name, city, total_hours
from cities_rank 
where ranking = 1;



