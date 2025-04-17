--ALL SQL TASK FROM 1 -7

--task 1
SELECT category.name AS category_title, COUNT(film.film_id) AS film_count
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY film_count DESC;


--task 2

SELECT 
    actor.actor_id,
    actor.first_name,
    actor.last_name,
    COUNT(rental.rental_id) AS total_rentals
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film.film_id = film_actor.film_id
JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY total_rentals DESC
LIMIT 10;


--task 3
SELECT category.name AS category_title, SUM(payment.amount) AS total_revenue
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film.film_id = film_category.film_id
JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY total_revenue DESC
LIMIT 1;

 

-- task 4 
 select (select distinct film.title), film.film_id, inventory.inventory_id
from film 
left join inventory on film.film_id = inventory.film_id
where inventory.inventory_id is null;

-- task 5

WITH actor_film_counts AS (
    SELECT 
        actor.actor_id,
        actor.first_name || ' ' || actor.last_name AS actor_name,
        COUNT(*) AS film_count
    FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film ON film.film_id = film_actor.film_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    WHERE category.name = 'Children'
    GROUP BY actor.actor_id, actor_name
),
ranked_actors AS (
    SELECT *,
           RANK() OVER (ORDER BY film_count DESC) AS rank
    FROM actor_film_counts
)
SELECT actor_name, film_count
FROM ranked_actors
WHERE rank <= 3;


-- task 6
SELECT 
    city.city, 
    COUNT(*) AS active_customers
FROM city
JOIN address ON address.city_id = city.city_id
JOIN customer ON customer.address_id = address.address_id
WHERE customer.active = 1
GROUP BY city.city;
-- task 7

WITH category_rental_hours AS (
    SELECT 
        city.city AS city_name,
        category.name AS category_name,
        SUM(EXTRACT(EPOCH FROM (rental.return_date - rental.rental_date)) / 3600) AS total_rental_hours
    FROM city
    JOIN address ON address.city_id = city.city_id
    JOIN customer ON customer.address_id = address.address_id
    JOIN rental ON rental.customer_id = customer.customer_id
    JOIN inventory ON inventory.inventory_id = rental.inventory_id
    JOIN film ON film.film_id = inventory.film_id
    JOIN film_category ON film_category.film_id = film.film_id
    JOIN category ON category.category_id = film_category.category_id
    WHERE city.city ILIKE 'A%'  -- cities that start with "A"
       OR city.city LIKE '%-%'  -- cities that contain a "-"
    GROUP BY city.city, category.name
),
ranked_categories AS (
    SELECT *,
        RANK() OVER (PARTITION BY city_name ORDER BY total_rental_hours DESC) AS rank
    FROM category_rental_hours
)
SELECT city_name, category_name, total_rental_hours
FROM ranked_categories
WHERE rank = 1;

