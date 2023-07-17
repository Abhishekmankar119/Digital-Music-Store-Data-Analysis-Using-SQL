/* Quastion - Answers */

/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
select first_name, last_name, title, Levels from employee 
order by Levels desc limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country, count(*) as Invoices from invoice 
group by billing_country order by Invoices desc;

/* Q3: What are top 3 values of total invoice? */
select * from invoice order by total desc limit 3;
/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city 
we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as Invoice_Total from invoice 
group by billing_city order by Invoice_Total desc 
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c1.customer_id, first_name, last_name, billing_country, Sum(total) as Total_Spending
from customer as c1
join invoice as i1 on c1.customer_id = i1.customer_id
group by c1.customer_id
order by Total_Spending desc
limit 1;
/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

select distinct first_name, last_name, email
from customer as c1
join invoice as i1 on c1.customer_id = i1.customer_id
join invoice_line as i2 on i1.invoice_id = i2.invoice_id
where track_id in (
select track_id from track as t1
join genre as g1 on t1.genre_id = g1.genre_id
where g1.name = 'Rock'
)
order by email asc;

/* Method 2 */
select distinct First_name as FirstName, Last_name as LastName, Email, g1.name as GenreName
from customer as c1
join invoice as i1 on c1.customer_id = i1.customer_id
join invoice_line as i2 on i1.invoice_id = i2.invoice_id
join track as t1 on t1.track_id = i2.track_id
join genre as g1 on t1.genre_id = g1.genre_id
where g1.name Like 'Rock'
order by Email asc;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT ar.artist_id, ar.name, COUNT(ar.artist_id) AS number_of_songs
from track as tr
join album as al on al.album_id = tr.album_id
join artist as ar on ar.artist_id = al.artist_id
join genre as ge on ge.genre_id = tr.genre_id
where ge.name like 'Rock'
group by ar.artist_id ORDER BY number_of_songs DESC LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name, milliseconds from track
where milliseconds >
(select avg(milliseconds) as `Avg Track Length` from track)
order by milliseconds;

/* Question Set 3 - Advance */
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, 
artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

With best_selling_artist as (
select ar.artist_id, ar.name, sum(i1.unit_price * i1.quantity) as Total_Sales
from invoice_line as i1
join track as t1 on i1.track_id = t1.track_id
join album as al on t1.album_id = al.album_id
join artist as ar on al.artist_id = ar.artist_id
group by ar.artist_id
order by Total_Sales desc
limit 1)

select c1.customer_id, c1.first_name, c1.last_name, bsa.name as artist_Name, SUM(i1.unit_price * i1.quantity) AS amount_spent 
from invoice as i2
join customer as c1 on i2.customer_id = c1.customer_id
join invoice_line as i1 on i1.invoice_id = i2.invoice_id
join track as t1 on i1.track_id = t1.track_id
join album as al on t1.album_id = al.album_id
JOIN best_selling_artist bsa on bsa.artist_id = al.artist_id
GROUP BY c1.customer_id, c1.first_name, c1.last_name, bsa.name
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

WITH popular_genre AS
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY genre.name ASC, customer.country asc
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */


With Customter_with_country AS(
select c1.customer_id, first_name, last_name, billing_country, sum(total) as Total_Spent,
row_number() over(partition by billing_country order by sum(total) desc) as Rownum
from invoice as i1
join customer as c1 on i1.customer_id = c1.customer_id
group by c1.customer_id, first_name, last_name, billing_country
order by billing_country Asc, Total_Spent desc
)
select * from Customter_with_country where Rownum <=1;