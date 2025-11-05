/* One-to-Many: where a given row within a table can be referenced by multiple rows in
another table */

/* Check number of booth numbers available */
SELECT booth_number
FROM booth -- 12 booth numbers available

/* Compare how many booth_numbers are in the vendor_booth_assignments, one select with distinct, one without. */
SELECT booth_number
FROM vendor_booth_assignments -- 921 rows; There are 921 booth_number rows in vendor_booth_assignments. 

SELECT DISTINCT booth_number
FROM vendor_booth_assignments -- 7 rows; There are 7 unique booth numbers assigned to vendor booths.

/* Compare how many booth_numbers and vendor_id are in vendor_booth_assignments, one select with distinct, one without. */
SELECT booth_number, vendor_id
FROM vendor_booth_assignments -- 921 rows. There are 921 booth_number and vendor_id rows. 

SELECT DISTINCT booth_number, vendor_id
FROM vendor_booth_assignments -- 11 rows.

/* Compare how many booth_numbers, vendor_id and market_date are in vendor_booth_assignments, one select with distinct, one without. */
SELECT booth_number, vendor_id, market_date
FROM vendor_booth_assignments -- 921 rows

SELECT DISTINCT booth_number, vendor_id, market_date
FROM vendor_booth_assignments -- 921 rows


/* Assignment 1 - Section 2 */

/* Write a query that returns everything in the customer table. */

SELECT customer_id, customer_first_name, customer_last_name, customer_postal_code
FROM customer

SELECT * 
FROM customer

/* Write a query that displays all of the columns and 10 rows from the customer table, sorted by customer_last_name, then customer_first_ name. */
SELECT customer_id, customer_first_name, customer_last_name, customer_postal_code
FROM customer
ORDER BY customer_last_name, customer_first_name
LIMIT 10;

/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. */
SELECT *
FROM customer_purchases
WHERE product_id = 4

SELECT *
FROM customer_purchases
WHERE product_id = 9

SELECT *
FROM customer_purchases
WHERE product_id IN (4,9)

SELECT *
FROM customer_purchases
WHERE product_id = 4
OR product_id = 9

/* 2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_to_customer_per_qty), filtered by customer IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN */
	
SELECT product_id, vendor_id, market_date, customer_id, quantity, cost_to_customer_per_qty, transaction_time, (quantity*cost_to_customer_per_qty) AS price
FROM customer_purchases
WHERE customer_id BETWEEN 8 AND 10

/* CASE - Q1 */
SELECT product_id, product_name
, CASE WHEN product_qty_type = 'unit' 
	THEN 'unit' 
	ELSE 'bulk'
END prod_qty_type_condensed
FROM product;

/* CASE - Q2  Add a column to the previous query called `pepper_flag` that outputs a 1 if the product_name contains the word “pepper” (regardless of capitalization), and otherwise outputs 0.
 */
SELECT product_id, product_name
, CASE WHEN product_qty_type = 'unit' THEN 'unit' 
	ELSE 'bulk'
	END AS prod_qty_type_condensed
, CASE WHEN product_name LIKE '%pepper%' 
	THEN 1
	ELSE 0
	END AS pepper_flag 	
FROM product
 
/* Section 2 - JOIN 1. Write a query that `INNER JOIN`s the `vendor` table to the `vendor_booth_assignments` table on the `vendor_id` field they both have in common, 
and sorts the result by `vendor_name`, then `market_date`. */

SELECT
v.vendor_id,
vendor_name,
vendor_type,
vendor_owner_first_name,
vendor_owner_last_name,
booth_number,
market_date
FROM vendor AS v
INNER JOIN vendor_booth_assignments AS vb
	ON v.vendor_id = vb.vendor_id
	ORDER BY vendor_name, market_date

/* Secton 3 - AGGREGATE 1. Write a query that determines how many times each vendor has rented a booth at the farmer’s market by counting the vendor booth assignments per `vendor_id`.  */

SELECT 
COUNT(booth_number)
, vendor_id
FROM vendor_booth_assignments
GROUP BY vendor_id

/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper sticker to everyone who has ever spent more than $2000 at the market. 
Write a query that generates a list of customers for them to give stickers to, sorted by last name, then first name.
**HINT**: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword.  */

SELECT
cp.customer_id,
product_id,
quantity,
cost_to_customer_per_qty,
customer_first_name,
customer_last_name,
market_date,
transaction_time
	FROM customer_purchases AS cp
	LEFT JOIN customer AS c
	ON cp.customer_id = c.customer_id
	ORDER BY customer_last_name, customer_first_name
	
	
SUM(quantity*cost_to_customer_per_qty) AS purchase_total
	, customer_id
	GROUP BY customer_id

/* TEMP TABLE 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal
**HINT**: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted (there are five columns to be inserted, I've given you the details, but not the syntax) 
To insert the new row use VALUES, specifying the value you want for each column:  
`VALUES(col1,col2,col3,col4,col5)`
*/

/* DATE 
1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.
**HINT**: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month and year are!

2. Using the previous query as a base, determine how much money each customer spent in April 2022. Remember that money spent is `quantity*cost_to_customer_per_qty`.
**HINTS**: you will need to AGGREGATE, GROUP BY, and filter...but remember, STRFTIME returns a STRING for your WHERE statement!!
*/








	
	
-- Number of unique vendor_id values
SELECT COUNT(DISTINCT vendor_id)
FROM vendor_booth_assignments

-- Number of rows with unique combinations of vendor_id and booth_number
SELECT COUNT(*)
From (
	SELECT DISTINCT vendor_id, booth_number
	FROM vendor_booth_assignments
) AS number_vendor_booths

-- Sum of rows with unique combinations of vendor_id and booth_number
SELECT COUNT(*) FROM vendor_booth_assignments




FROM (
	SELECT DISTINCT vendor_id
vendor_booth_assignments



 
