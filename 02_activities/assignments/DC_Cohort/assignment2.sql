/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT
product_name || ', ' || coalesce(product_size, '')|| ' (' || coalesce(product_qty_type, 'unit') || ')'
FROM product;


--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

SELECT 
market_date
,customer_id
,ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS [customer_visit]
FROM customer_purchases
GROUP BY market_date, customer_id;

/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

SELECT 
market_date
,customer_id

FROM (
	SELECT 
	market_date
	,customer_id
	,ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date DESC) AS [customer_visit]
	FROM customer_purchases	
) x

WHERE x.customer_visit = 1;

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

SELECT *
,COUNT(product_id) OVER(PARTITION BY customer_id, product_id ORDER BY product_id,customer_id) AS [times_product_purchased]
FROM customer_purchases;

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

SELECT *
    , TRIM(NULLIF(SUBSTR(product_name, INSTR(product_name, '-') + 1), product_name)) AS description
FROM product;

-- work inside out; remember to add 'one' to substring the product name, to capture string characters one position right of the hythen; experiment with order of commands; check https://www.w3schools.com/sql/func_mysql_nullif.asp

/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

SELECT *
    , TRIM(NULLIF(SUBSTR(product_name, INSTR(product_name, '-') + 1), product_name)) AS description
FROM product

WHERE product_size REGEXP '\d'

--located REGEX command in regexr.com: character classes > digit > example (for syntax)

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */


-- Use a CTE to calculate sum of sales by market date using customer_purchases table
WITH sales_by_date AS (
    SELECT 
        cp.market_date,
        SUM(quantity * cost_to_customer_per_qty) AS sales
    FROM customer_purchases cp
    GROUP BY cp.market_date
),
-- Use a second CTE to rank customer sales by market date, create best_day and worst_day sales by date
sales_ranking AS (
    SELECT 
        market_date,
        sales,
        ROW_NUMBER() OVER (ORDER BY sales DESC) AS best_day,
        ROW_NUMBER() OVER (ORDER BY sales ASC) AS worst_day
    FROM sales_by_date
)
-- Use UNION command to stack the sales_ranking CTEs for best_day and worst_day of customer sales
-- Generate the "best day" variable value
SELECT 
    market_date,
    sales,
    'Best Day' AS sales_type
FROM sales_ranking
WHERE best_day = 1

UNION

-- Generate the "worst day" variable value
SELECT 
    market_date,
    sales,
    'Worst Day' AS sales_type
FROM sales_ranking
WHERE worst_day = 1;

/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

-- Create tempory table with required vendor and product columns called new_vendor_inventory: (DISTINCT) vendor_id, product_id, original_price from vendor_inventory
-- if a table named new_vendor_inventory exists, delete it, other do NOTHING
DROP TABLE IF EXISTS temp.new_vendor_inventory;

--make the table
CREATE TABLE temp.new_vendor_inventory AS

-- definition of the table
SELECT DISTINCT
	vi.vendor_id
	,product_id
	,original_price
	,original_price*5 as total_vendor_sales
FROM vendor_inventory vi;

-- Left join new_vendor_inventory temp table with vendor_name from vendor table on vi.vendor_id, to add vendor_name colum to the tempory table;
-- Left join product_name from product table on product_id, to add product names to the temporary table

DROP TABLE IF EXISTS temp.new_new_vendor_inventory;

CREATE TABLE temp.new_new_vendor_inventory AS

SELECT
	nvi.vendor_id
	,nvi.product_id
	,nvi.total_vendor_sales
	,v.vendor_name 
	,p.product_name
FROM temp.new_vendor_inventory as nvi
LEFT JOIN vendor as v
	ON nvi.vendor_id = v.vendor_id
LEFT JOIN product as p
	ON nvi.product_id = p.product_id;

-- Cross join vendor products from new_new_vendor_inventory with all 26 customers on record in customer table
SELECT
	nnvi.vendor_name
	,nnvi.product_name
	,SUM(nnvi.total_vendor_sales) AS total_sales
FROM customer c
CROSS JOIN temp.new_new_vendor_inventory nnvi
GROUP BY nnvi.vendor_name, nnvi.product_name;

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

-- For information on 'CURRENT_TIMESTAMP', I referred to: https://www.geeksforgeeks.org/postgresql/postgresql-current_timestamp-function/

DROP TABLE IF EXISTS temp.product_units;
CREATE TABLE temp.product_units AS
	SELECT * 
	,CURRENT_TIMESTAMP AS snapshot_timestamp 
FROM product
WHERE product_qty_type = 'unit';

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO temp.product_units
VALUES(24,'Chocolate Cake','2 lbs',3,'unit',CURRENT_TIMESTAMP)

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM temp.product_units
WHERE product_id = 24;
SELECT * 
FROM temp.product_units

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

ALTER TABLE temp.product_units
ADD current_quantity INT;

-- Obtain the most recent quantity per product_id in vendor_inventory table using a subquery
SELECT
    market_date
    ,quantity,
    ,product_id
FROM (
	SELECT
		market_date
		,quantity
		,product_id
		,DENSE_RANK() OVER(PARTITION BY product_id ORDER BY market_date DESC) AS [dense_rank]
	FROM vendor_inventory 
)
WHERE dense_rank = 1

-- Use UPDATE to change the current_quantity column to the last quantity value using query code developed above
UPDATE temp.product_units
SET current_quantity = (
	SELECT COALESCE(quantity, 0) -- return non-null quantity values from the vendor_inventory table, or if quantity value is null, return a zero
	FROM (
		SELECT 
			market_date
			,product_id
			,quantity
			,DENSE_RANK() OVER(PARTITION BY product_id ORDER BY market_date DESC) AS [dense_rank]
		FROM vendor_inventory 
) ranked -- alias for subquery
		WHERE dense_rank = 1 
		AND ranked.product_id = product_units.product_id -- match the subquery and temp table product_id by row
) -- end of SET function
-- Cannot specify a particular row; therefore, specify all selected rows from the vendor inventory
WHERE product_units.product_id IN (SELECT DISTINCT product_id FROM vendor_inventory)

-- Change current_quantity null values to 0
UPDATE temp.product_units
SET current_quantity = 0
WHERE current_quantity IS NULL;

