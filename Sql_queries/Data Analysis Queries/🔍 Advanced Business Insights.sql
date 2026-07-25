-- 🔍 Advanced Business Insights
-- Which products generate above-average revenue?
SELECT 
	item,
	SUM(quantity) AS total_qty_sold,
	SUM(total_spent) AS total_revenue
FROM clean_cafe_sales_data
GROUP BY item
HAVING 
	SUM(total_spent)>
				(SELECT AVG(total_revenue) FROM
												(SELECT 
													item, 
													SUM(total_spent) AS total_revenue 
												  FROM clean_cafe_sales_data GROUP BY item))

-- Which store-product combinations generate the highest revenue?
WITH store_product_revenue AS (SELECT 
	store_location ,
	item,
	SUM(quantity) AS total_quantity_sold,
	SUM(total_spent) AS total_revenue,
	DENSE_RANK() OVER(ORDER BY SUM(total_spent) DESC) AS rnk
FROM clean_cafe_sales_data
GROUP BY 
	store_location,
	item
	)
SELECT
	store_location ,
	item ,
	total_quantity_sold,
	total_revenue
FROM store_product_revenue
WHERE rnk = 1	
-- Which products contribute to 80% of total revenue (Pareto Analysis)?
SELECT SUM(total_spent) FROM clean_cafe_sales_data

WITH product_revenue_distribution AS (
	SELECT 
		item,
		SUM(total_spent) AS total_revenue,
		SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER() AS pct_contribution,
		DENSE_RANK() OVER(ORDER BY SUM(total_spent) DESC) AS rnk
	FROM clean_cafe_sales_data
		GROUP BY item
),
pareto AS(
	SELECT item,
		total_revenue,
		ROUND(pct_contribution,2) AS pct_contribution,
		ROUND(SUM(pct_contribution) OVER(ORDER BY total_revenue DESC ),2) AS cumulative_contribution_pct
	FROM product_revenue_distribution
)
SELECT * 
	FROM 
		(
		SELECT *,
			LAG(cumulative_contribution_pct) OVER(ORDER BY total_revenue DESC) AS previous_cumulative_contribution_pct
		FROM pareto
		) t
	WHERE
		cumulative_contribution_pct <=80 OR 
		(previous_cumulative_contribution_pct < 80 AND  cumulative_contribution_pct > 80)


-- What is the revenue share percentage of each product?
SELECT 
	item,
	SUM(total_spent) AS total_revenue,
	ROUND(SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER(),2) AS revenue_share_pct
FROM clean_cafe_sales_data
	GROUP BY item
	ORDER BY total_revenue DESC 
-- Which products have high sales volume but low revenue?
WITH product_sales AS (
SELECT 
	item,
	SUM(quantity) AS total_quantity_sold,
	SUM(total_spent) AS total_revenue,
	ROUND(SUM(quantity)*100.0/SUM(SUM(quantity)) OVER(),2) AS sold_quantity_share_pct,
	ROUND(SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER(),2) AS revenue_share_pct
FROM clean_cafe_sales_data
	GROUP BY item
	)
SELECT * FROM
	(SELECT * , 
	DENSE_RANK() OVER(ORDER BY  total_quantity_sold DESC ) AS quantity_sold_rnk,
	DENSE_RANK() OVER(ORDER BY  total_revenue ) AS revenue_rnk
FROM product_sales) t 
WHERE t.quantity_sold_rnk <= 3
AND t.revenue_rnk <= 3;

-- Which products have low sales volume but high revenue?WITH product_sales AS (
WITH product_sales AS (
SELECT 
	item,
	SUM(quantity) AS total_quantity_sold,
	SUM(total_spent) AS total_revenue,
	ROUND(SUM(quantity)*100.0/SUM(SUM(quantity)) OVER(),2) AS sold_quantity_share_pct,
	ROUND(SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER(),2) AS revenue_share_pct
FROM clean_cafe_sales_data
	GROUP BY item
	)
SELECT * FROM
	(SELECT * , 
	DENSE_RANK() OVER(ORDER BY  total_quantity_sold  ) AS quantity_sold_rnk,
	DENSE_RANK() OVER(ORDER BY  total_revenue DESC ) AS revenue_rnk
FROM product_sales) t 
WHERE t.quantity_sold_rnk <= 4
AND t.revenue_rnk <= 3;

-- What is the relationship between quantity sold and revenue generated?
WITH product_revenue AS (
	SELECT 
		item,
		SUM(quantity) AS total_sold_qty,
		SUM(total_spent) AS total_revenue
	FROM clean_cafe_sales_data
	GROUP BY item	
),
sold_quantity_and_revenue_pct AS 
(
SELECT *,
	ROUND(total_revenue/total_sold_qty,2) AS average_selling_price,
	ROUND(total_sold_qty*100.0/SUM(total_sold_qty) OVER(),2) AS sold_qty_contribution_pct,
	ROUND(total_revenue*100.0/SUM(total_revenue) OVER(),2) AS revenue_contribution_pct,
	DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_rank_by_revenue,
	DENSE_RANK() OVER(ORDER BY total_sold_qty DESC) AS product_rank_by_qty_sold
FROM product_revenue
)
SELECT item,
	total_sold_qty,
	total_revenue,
	average_selling_price,
	sold_qty_contribution_pct,
	revenue_contribution_pct,
	product_rank_by_qty_sold,
	product_rank_by_revenue
FROM sold_quantity_and_revenue_pct
ORDER BY total_revenue DESC
-- Which products should be prioritized based on revenue contribution?
WITH product_revenue AS (
	SELECT 
		item,
		SUM(quantity) AS total_sold_qty,
		SUM(total_spent) AS total_revenue
	FROM clean_cafe_sales_data
	GROUP BY item	
),
sold_quantity_and_revenue_pct AS 
(
SELECT *,
	ROUND(total_revenue/total_sold_qty,2) AS average_selling_price,
	ROUND(total_sold_qty*100.0/SUM(total_sold_qty) OVER(),2) AS sold_qty_contribution_pct,
	ROUND(total_revenue*100.0/SUM(total_revenue) OVER(),2) AS revenue_contribution_pct,
	DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_rank_by_revenue,
	DENSE_RANK() OVER(ORDER BY total_sold_qty DESC) AS product_rank_by_qty_sold
FROM product_revenue
)
SELECT item,
	total_sold_qty,
	total_revenue,
	average_selling_price,
	sold_qty_contribution_pct,
	revenue_contribution_pct,
	product_rank_by_qty_sold,
	product_rank_by_revenue
FROM sold_quantity_and_revenue_pct
WHERE product_rank_by_revenue <=3