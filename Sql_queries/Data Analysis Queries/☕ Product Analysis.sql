-- ☕ Product Analysis
-- Which are the top 5 best-selling products by quantity?
WITH product_sales AS (
SELECT 
	item,
	SUM(quantity) AS total_quantity_sold
FROM clean_cafe_sales_data
GROUP BY item
)
SELECT * ,
ROUND(total_quantity_sold*100.0/SUM(total_quantity_sold) OVER(),2) AS total_quantity_contribution_pct,
DENSE_RANK() OVER(ORDER BY total_quantity_sold DESC) AS product_rank
FROM product_sales
ORDER BY total_quantity_sold DESC LIMIT 5
-- Which products generate the highest revenue?
WITH product_revenue AS (
		SELECT 
			item ,
			SUM(quantity) AS quantity_sold, 
			SUM(total_spent) AS total_revenue 
		FROM clean_cafe_sales_data
		GROUP BY item),
	product_ranked AS (
		SELECT 
			item ,		
			quantity_sold, 
			total_revenue , 
			ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER(),2)AS total_revenue_contribution_pct,
			DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_revenue_rank
		FROM product_revenue)
		SELECT * 
		FROM product_ranked
		WHERE product_revenue_rank = 1
-- Which products generate the lowest revenue?
WITH product_revenue AS (
		SELECT 
			item ,
			SUM(quantity) AS quantity_sold, 
			SUM(total_spent) AS total_revenue 
		FROM clean_cafe_sales_data
		GROUP BY item),
	product_ranked AS (
		SELECT 
			item ,		
			quantity_sold, 
			total_revenue , 
			ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER(),2)AS total_revenue_contribution_pct,
			DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_revenue_rank
		FROM product_revenue)
		SELECT * 
		FROM product_ranked
		WHERE product_revenue_rank = (SELECT MAX(product_revenue_rank) FROM product_ranked );
-- What percentage of total revenue does each product contribute?
WITH product_revenue AS (
	SELECT 
		item , 
		SUM(quantity) AS total_quantity_sold,
		SUM(total_spent) AS total_revenue
	FROM clean_cafe_sales_data
	GROUP BY item)
	SELECT 
		* , 
		ROUND(total_revenue *100.0 /SUM(total_revenue) OVER() ,2) AS total_revenue_contribution_pct,
		DENSE_RANK() OVER(ORDER BY total_revenue DESC ) AS rev_rank
	FROM product_revenue
-- Which products have the highest average transaction value?
WITH product_avg_transaction AS (SELECT 
	item , 
	SUM(quantity) AS total_quantity_sold,
	ROUND(AVG(total_spent),2) AS average_transaction_value
FROM clean_cafe_sales_data GROUP BY item),
 product_rank AS (
SELECT * ,
DENSE_RANK() OVER(ORDER BY average_transaction_value DESC) AS product_transaction_rank
FROM product_avg_transaction
)
SELECT item ,
	total_quantity_sold,
	average_transaction_value,
	product_transaction_rank
FROM product_rank
WHERE product_transaction_rank =1;
-- What is the average quantity sold per product?
WITH product_avg_quantity_sold AS(
	SELECT 
		item , 
		ROUND(AVG(quantity),2) AS avg_quantity_sold
	FROM clean_cafe_sales_data GROUP BY item),
	product_rank AS (
	SELECT 
		item,
		avg_quantity_sold,
		DENSE_RANK() OVER(ORDER BY avg_quantity_sold DESC) AS product_rank
	FROM product_avg_quantity_sold
)
SELECT 
	item , 
	avg_quantity_sold ,
	product_rank  
FROM product_rank


--Which product sold the highest quantity in each month?
WITH product_data AS (
	 SELECT 
	 	*,
		TO_CHAR(transaction_date,'Mon')AS transaction_month,
		EXTRACT(MONTH FROM transaction_date) AS transaction_month_num FROM clean_cafe_sales_data
),
 month_wise_product_sales_rnk AS (
	SELECT 
		* , 
		DENSE_RANK() OVER(PARTITION BY transaction_month_num ORDER BY total_sold_qty DESC ) AS product_rnk
	FROM (SELECT 
			transaction_month , 
			transaction_month_num ,
			item,SUM(quantity) AS total_sold_qty
    FROM product_data
    GROUP BY transaction_month ,
			 item ,
			 transaction_month_num
         ) t
ORDER BY transaction_month_num)
	SELECT 
		transaction_month ,
		item,
		total_sold_qty 
	FROM month_wise_product_sales_rnk 
	WHERE product_rnk =1
