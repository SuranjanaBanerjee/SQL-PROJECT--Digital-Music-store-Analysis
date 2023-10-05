# Q.1) who is the senior most employee based on job title?
use music_data;
select * from employee
order by levels desc 
limit 1;

# Q.2) Which countries have the most invoices?
select count(*) as c ,billing_country 
 from invoice
 group by billing_country
 order by c desc;
 
 # Q.3) What are the top 3 values of total invoices?
 select total from invoice
 order by total desc
 limit 3;
 
 # Q.4) Which city has the best customers? We would like to throw a promotional Music Festival in the city- 
 #   we made the most money.write a query that returns one city that has the highest sum of invoice totals.
 #   Return both the city name & sum of all invoice totals.
 select sum(total) as invoice_total ,billing_city 
 from invoice
 group by billing_city
 order by invoice_total desc;
 
 set sql_mode=(select replace(@@sql_mode,'only_full_group_by',''));
 
# Q.5) Who is the best customer? The customer who has spent the most money will be declared the best customer.-
#  write a query that returns the person who has spent the most money. 
SELECT any_value(customer.customer_id) as Customer_id, any_value(customer.first_name) as first_name , 
any_value(customer.last_name) as last_name , 
SUM(invoice.total) as invoice_total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by  customer.customer_id
order by invoice_total desc
limit 1; 

# Q.6) Write a query to return the email.first name,last name and genre of all Rock music listeners.
# Return your list ordered alphabetically by email starting with A.

select distinct customer.email as Email,customer.first_name as FirstName,customer.last_name as LastName ,genre.name as Name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
where genre.name like "Rock"
order by email;


# Q.7) Return all the track names that have a song length longer than the average song length.
#Return the name and milliseconds for each track;Order by the song length with the longest song listed first.

select name ,milliseconds
from track
where milliseconds > (
select avg(milliseconds) as avg_track_length
from track)
order by milliseconds desc;

# Q.8) Find how much amount spent by each customer on artist?
# Write a query to return customer name,artist name and total spent.

with best_selling_artist as(
    select any_value(artist.artist_id) as artist_id, any_value(artist.name) as artist_name,
	sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
    from invoice_line
	join track on track.track_id=invoice_line.track_id
    join album_all on album_all.album_id=track.album_id
    join artist on artist.artist_id=album_all.artist_id
    group by 1
    order by 3 desc
    limit 1
)
select any_value(c.customer_id) as customerId,any_value(c.first_name) as FirstName,any_value(c.last_name)as lastName,bsa.artist_name,
sum(il.unit_price *il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album_all alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5;

# Q.9)  We want to find out the most popular music Genre for each country.
# We determine the most popular genre as the genre with the highest amount of purchases.
# Write a query that returns each country along with the top genre.
# For countries where the maximum number of purchases is shared return all genres.

with popular_genre as
(
     select count(invoice_line.quantity) as purchase, customer.country, genre.name , genre.genre_id,
     row_number() over (partition by customer.country order by Count(invoice_line.quantity) desc) as RowNo
     from invoice_line
     join invoice on invoice.invoice_id=invoice_line.invoice_id
     join customer on customer.customer_id=invoice.customer_id
     join track on track.track_id=invoice_line.track_id
     join genre on genre.genre_id=track.genre_id
     group by 2,3,4
     order by 2 asc, 1 desc
     )
select * from popular_genre where RowNo <= 1;

 set global sql_mode=(select replace(@@sql_mode, 'ONLY_FULL_GROUP_BY',''));
 
 # Q.10) Write a query that determines the customer that has spent the most on music for each country.
 #Write a query that returns the country along with the top customer and how much they spent.
 #For countries where the top amount spent is shared,provide all customers who spent this amount.

with recursive
    customer_with_country as (
    select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending
    from invoice
    join customer on customer.customer_id=invoice.customer_id
    group by 1,2,3,4
    order by 2,3 desc
    ),
country_max_spending as(
	select billing_country, max(total_spending) as max_spending
    from customer_with_country
    group by billing_country)
    
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name,cc.customer_id
from customer_with_country cc
join country_max_spending ms on cc.billing_country=ms.billing_country
where cc.total_spending=ms.max_spending
order by 1;

















 
 
 
 
 
 
 