-- Q1: Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

-- Q2: Which countries have the most Invoices?

SELECT COUNT(billing_country) AS most_invoice, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY most_invoice

-- Q3: What are top 3 values of total invoice?

SELECT DISTINCT total FROM invoice
ORDER BY total DESC
LIMIT 3

-- Q4: Whcih city has the best customers? we would like to throw a promotional music festival
-- in the city we made the most money. write a query that returns one city that has the highest
-- sum of invoice totals. returns both the city name&sum of all invoice totals

SELECT SUM(total) AS most_total,billing_city
FROM invoice
GROUP BY billing_city
ORDER By most_total DESC

-- Q5: Who is the best customer? the customer who has spent the most money will be declared the
-- best customer. write a query that returns the person who spent the most money

SELECT customer.*, SUM(invoice.total) As most_money
FROM invoice
INNER JOIN customer
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY most_money DESC
LIMIT 1

-----------------Question Set 2 Moderate----------------

-- Q1: Write query to return the email, first name, last name & genre of all rock music 
-- listeners return your list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre
	ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- Q2: Let's invite the artist who have written the most rock music in our dataset. write query
-- that returns the artist name and total track count of the top 10 rock bands

SELECT artist.name,artist.artist_id, COUNT(artist.artist_id) AS number_of_song
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_song DESC
LIMIT 10

_______2nd Choice-----------

SELECT artist.name,artist.artist_id, COUNT(artist.artist_id) AS number_of_song
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_song DESC


-- Q3: Return all the track names that have a song length longer than the average song length
-- return the name and milliseconds for each track. order by the song length with the longest 
-- songs listed first

SELECT name , milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_track_length FROM track)
ORDER BY milliseconds DESC

---------------------Question Set 3 Advance-------------------

-- Q1: Find how much amount spent by each customer on artist? write a query to return customer
-- name, artist name and total spent

WITH best_selling_artist AS(
	SELECT artist.name AS artist_name, artist.artist_id AS artist_id,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sale
	FROM invoice_line
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN album ON track.album_id = album.album_id
	JOIN artist ON album.artist_id = artist.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sale DESC
	LIMIT 1
)
SELECT customer.customer_id, customer.first_name, customer.last_name,
best_selling_artist.artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON track.album_id = album.album_id
JOIN best_selling_artist ON best_selling_artist.artist_id = album.artist_id
GROUP BY customer.customer_id,customer.first_name, customer.last_name,
best_selling_artist.artist_name
ORDER BY amount_spent DESC;


-- Q2: We want to find out the most popular music genre for each country. we determine the most
-- popular genre as the genre with the highest amount of purchases. writea query that returns
-- each country along with the top genre. For countries where the maximum number of purchases
-- is shared return all genres.

WITH popular_genre AS(
	SELECT COUNT(invoice_line.quantity) AS purchase, customer.country, genre.name,
	genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_no
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE row_no <=1


-- Q3: Write a query that determine the customer that has spent the most on music for each country
-- write a query that returns the country along with the top customer and how much they spent for
-- countries where the top amount spent is shared, provide all customers who spent this amount


WITH customer_with_country AS(
	SELECT customer.customer_id,first_name,last_name,billing_country, 
	SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS row_no
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_with_country WHERE row_no <= 1