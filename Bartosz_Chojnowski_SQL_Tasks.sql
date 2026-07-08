-- Output the number of movies in each category, sorted descending.
select category.category_id, category.name , count(film_id) as films
from film_category inner join category on film_category.category_id = category.category_id
group by category.category_id,  category.name
order by films desc;

-- Output the 10 actors whose movies rented the most, sorted in descending order.
select a.actor_id, a.first_name, a.last_name, count(r.rental_id ) as rental_count
from  film_actor fa
inner join actor a on fa.actor_id = a.actor_id
inner join inventory i on fa.film_id = i.film_id
inner join rental r on i.inventory_id = r.inventory_id
group by a.actor_id, a.first_name , a.last_name 
order by rental_count desc
limit 10;

--Output the category of movies on which the most money was spent.
select c.name , sum(p.amount) as sum_of_amount  
from category c 
 inner join film_category fc on c.category_id = fc.category_id
 inner join inventory i on fc.film_id = i.film_id 
 inner join rental r on i.inventory_id = r.inventory_id 
 inner join payment p on r.rental_id = p.rental_id 
 group by c.category_id , c.name
 order by sum_of_amount  desc
 limit 1;

--Print the names of movies that are not in the inventory. Write a query without using the IN operator.
select f.film_id  ,f.title
from film f 
left join inventory i on f.film_id = i.film_id
where i.film_id is null

--Output the top 3 actors who have appeared the most in movies in the “Children” category. If several actors have the same number of movies, output all of them.
with children_films as(
	select a.actor_id, a.first_name , a.last_name , count(fc.film_id) as number_of_app, 
	dense_rank() over (order by count(fc.film_id) desc) as ranking
	from actor a 
	inner join film_actor fa on a.actor_id = fa.actor_id
	inner join film_category fc on fa.film_id = fc.film_id
	inner join category c on fc.category_id = c.category_id
	where c.name = 'Children'
	group by a.actor_id , a.first_name , a.last_name
)
select actor_id, first_name, last_name, number_of_app
from children_films
where ranking <=3;

--Output cities with the number of active and inactive customers (active - customer.active = 1). Sort by the number of inactive customers in descending order.
select c2.city,
count(case when c.active = 1 then 1 end) as active_customers,
count(case when c.active = 0 then 1 end) as inactive_customers
from customer c 
inner join address a on c.address_id = a.address_id
inner join city c2  on a.city_id = c2.city_id
group by c2.city_id , c2.city 
order by inactive_customers desc;

--Output the category of movies that have the highest number of total rental hours in the city (customer.address_id in this city) and that start with the letter “a”. Do the same for cities that have a “-” in them. Write everything in one query.
with categories_by_city_hours as(
	select c3.city, c.name, r.rental_date, r.return_date, case 
		when c3.city ilike 'a%' then 'Cities start with A'
		when c3.city like '%-%' then 'Cities with -'
	end as city_group
	from category c 
	inner join film_category fc on c.category_id = fc.category_id
	inner join inventory i on fc.film_id = i.film_id 
	inner join rental r on i.inventory_id = r.inventory_id
	inner join customer c2  on r.customer_id = c2.customer_id
	inner join address a on c2.address_id = a.address_id
	inner join city c3  on a.city_id = c3.city_id
	where city ilike 'a%' or city like '%-%'
),
cities_rank as(
	select city_group, name, round(sum(extract(epoch from (return_date-rental_date))/3600),0) as total_hours,
	dense_rank() over( partition by city_group order by round(sum(extract(epoch from (return_date-rental_date))/3600),0) desc) as ranking
	from categories_by_city_hours
	group by city_group, name
)
select city_group, name , total_hours
from cities_rank 
where ranking = 1




