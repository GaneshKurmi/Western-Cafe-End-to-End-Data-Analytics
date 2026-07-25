-- 🏪 Store Performance Analysis
-- Which store location generates the highest revenue?
SELECT 
	store_location ,
	total_revenue,
	revenue_contribution_pct,
	store_rnk  
FROM (
	SELECT 
		store_location , 
		SUM(total_spent) AS total_revenue , 
		ROUND(SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER(),2) ||'%' AS revenue_contribution_pct,
		DENSE_RANK() OVER(ORDER BY SUM(total_spent) DESC) AS store_rnk
	FROM clean_cafe_sales_data GROUP BY store_location
	 ) t
WHERE store_rnk =1 ;
-- Which store location records the highest number of transactions?
SELECT 
	 store_location ,
	 total_transaction,
	 transaction_contribution_pct,
	 store_rnk  
FROM (
 		SELECT 
		 	store_location , 
			COUNT(*) AS total_transaction , 
            ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) ||'%' AS transaction_contribution_pct,
			DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS store_rnk
		FROM clean_cafe_sales_data GROUP BY store_location
	) t
WHERE store_rnk =1 ;
-- What is the average order value by store location?
SELECT store_location,
	ROUND(AVG(total_spent),2)AS average_order_value
FROM clean_cafe_sales_data
GROUP BY store_location;
-- Which products perform best at each store location?
WITH product_revenue AS (
		SELECT 
			store_location,
			item,
			SUM(total_spent) AS total_revenue
		FROM clean_cafe_sales_data
		GROUP BY store_location ,item
),
product_rnk AS (
		SELECT * , 
			   DENSE_RANK() OVER( PARTITION BY store_location ORDER BY total_revenue DESC) AS product_rank  
FROM product_revenue
)
		SELECT 
			store_location , 
			item , 
			total_revenue , 
			product_rank 
		FROM product_rnk
WHERE product_rank =1;
-- Which store contributes the highest percentage of overall revenue?
SELECT 
	store_location, 
	total_revenue,
 	total_contribution_percentage,
 	store_rnk
FROM 
 (
  SELECT 
	store_location , 
	SUM(total_spent) AS total_revenue,
	ROUND(SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER( ),2) AS total_contribution_percentage,
	DENSE_RANK() OVER( ORDER BY SUM(total_spent) DESC) AS store_rnk
  FROM clean_cafe_sales_data GROUP BY store_location
  ) t
WHERE store_rnk =1