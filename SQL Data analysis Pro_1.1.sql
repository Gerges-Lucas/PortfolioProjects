--Changes Over Years

select 
DATETRUNC(month, order_date) AS order_date, 
SUM(sales_amount) AS total_sales,
COUNT (DISTINCT customer_key) as total_customers,
SUM( quantity) AS total_quantity
From gold.fact_sales 
where order_date IS NOT NULL 
group by DATETRUNC(month, order_date) 
order by DATETRUNC(month, order_date) 

-------------------------------------------------------------------------------------------------

-- Changes Over Months 

select 
YEAR(order_date) AS order_year,
Month(order_date) AS order_month, 
SUM(sales_amount) AS total_sales,
COUNT (DISTINCT customer_key) as total_customers,
SUM( quantity) AS total_quantity
From gold.fact_sales 
where order_date IS NOT NULL 
group by Month(order_date), YEAR(order_date)
order by Month(order_date), YEAR(order_date)

-----------------------------------------------------------------------------------------

-- cumulative analysis
-- aggregate the data progressively over time
-- " how our business is growing or declining over time"

-- running total sales by year
-- moving average of sales by month 

-- for the measure : 
-- calculate the total sales per month
-- and the running total of sales over time

-- adding each row's value to the sum of all the previous row's values
select 
order_date, 
total_sales, 
SUM (total_sales) OVER (PARTITION BY order_date order by order_date) as running_total_sales
from 
(
select 
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales 
from gold.fact_sales
where order_date IS NOT NULL 
group by DATETRUNC(MONTH, order_date) 
) t

-- cumulative by year
select 
order_date, 
total_sales, 
SUM (total_sales) OVER (order by order_date) as running_total_sales,
AVG(avg_price) OVER ( ORDER BY order_date) AS moving_average_price
from 
(
select 
DATETRUNC(year, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG (price) AS avg_price 
from gold.fact_sales
where order_date IS NOT NULL 
group by DATETRUNC(year, order_date) 
) t

--------------------------------------------------------------------------------------

-- Performance analysis 
-- which is the current value Comparing with the target value
-- helps measure success and compare performance
-- to find it we make Current [measure] - target [measure]
-- like >> current sales - average sales // current year sales - pervious year sales


/* analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales*/
WITH yearly_product_sales AS (
select 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
from gold.fact_sales f 
left join gold.dim_products p 
on f.product_key = p.product_key
where order_date IS NOT NULL 
group by year(f.order_date),
p.product_name
) 
Select 
order_year,
product_name, 
current_sales,
AVG(current_sales) OVER ( PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER ( PARTITION BY product_name) AS diff_avg ,
CASE WHEN current_sales - AVG(current_sales) OVER ( PARTITION BY product_name) > 0 THEN 'Above avg'
     WHEN current_sales - AVG(current_sales) OVER ( PARTITION BY product_name) < 0 THEN 'Below avg'
	 Else 'Avg'
END avg_change,
-- year over year analysis > yoy
LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) previous_year_sales,
current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as diff_PY,
CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
     WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 Else 'No change'
END PY_change
from yearly_product_sales
order by product_name, order_year

-------------------------------------------------------------------------------------------------

-- Part to whole analysis
-- analyze how an individual part is performing to the overall, allowing us to understand which category has the greatest impact on the business

-- ( measure] / total[measure] ) * 100 by [dimension]
-- (sales / total sales) * 100 by category, (quantity / total quantity) * 100 by country

-- which categories contribute the most to overall sales
WITH category_sales AS (
SELECT 
category, 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
group by category
)
-- to display aggregation at multiple levels in the results use window function
SELECT 
category, 
total_sales,
SUM (total_sales) OVER () overall_sales,
CONCAT (ROUND((CAST ((total_sales) AS FLOAT )/ SUM (total_sales) OVER () ) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC
-------------------------------------------------------------------------------------------------------------

-- Data segmentation 
-- Group the data based on a spesific range
-- helps understand the correlation between two measures
-- measure by measure >> total products by sales rang // total customers by age

/*segment products into cost ranges and count how many products
fall into each segment */
WITH product_segments AS (
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN  'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range 
FROM gold.dim_products
)

SELECT 
cost_range,
COUNT (product_key) AS total_products 
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

-------------------------------------------------------
/* Group customers into three segments based on their spending behavior : 
	-VIP : Cstomers with at least 12 months of history and spending more than $5,000.
	-Regular : Customers with at least 12 months of history but spending $5,000 or less.
	-New : Customers with a lifespan less than 12 months 
And find the total number of customers by each group */

WITH customer_spending AS (
SELECT 
c.customer_key,
SUM (f.sales_amount) AS total_spending,
MIN (order_date) AS first_order,
MAX (order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT
customer_segement,
COUNT(customer_key) AS total_customers
FROM (
	SELECT 
	customer_key,
	total_spending,
	lifespan,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END customer_segement 
	FROM customer_spending ) t
GROUP BY customer_segement
ORDER BY total_customers DESC
---------------------------------------------------------------------------------------------------------------

-- Build Customer Report
-- purpose : 
	/* this report consolidates custmer metrics and behaviors

Highlights : 
	1. gathers essential fields such as nams, ages, and tranaction details.
	2. segments customers into categories (VIP, Regular, New) and age groups.
	3. aggregates customer-level metrics : 
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. calculate valuable KPIs :
		- recency (months since last order)
		- average order value 
		- average monthly spend 
================================================================================
*/ 
CREATE VIEW gold.report_customers AS 
WITH base_query AS ( 
-- 1) Base Query : retrieves core columns from tables
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.quantity,
f.sales_amount,
c.customer_key,
c.customer_number,
DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age,
CONCAT (c.first_name, ' ', c.last_name) AS customer_name
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL 
),

customer_aggregation AS (
-- 2) Customer Aggregations : Summarizes key mertics at customer level 
SELECT 
	customer_key,
	customer_number,
	age,
	customer_name,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX (order_date) AS last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query 
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age)

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		 WHEN age < 20 THEN 'Under 20'
		 WHEN age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN age BETWEEN 30 AND 39 THEN '30-39'
		 WHEN age BETWEEN 40 AND 49 THEN '40-49'
		 ELSE '50 and above'
	END AS age_group,
	CASE 
		 WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment,
	last_order,
	DATEDIFF(MONTH, last_order, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
-- compuate average order value (AVO)
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END AS avg_order_value,
-- compuate average monthly spend
	CASE WHEN lifespan = 0 THEN total_sales 
		 ELSE total_sales / lifespan
	END AS avg_monthly_spend

FROM customer_aggregation


/*=================================================================================================================*/

SELECT
customer_segment,
COUNT (customer_number) AS total_customers,
SUM (total_sales) AS total_sales
FROM gold.report_customers
GROUP BY customer_segment



