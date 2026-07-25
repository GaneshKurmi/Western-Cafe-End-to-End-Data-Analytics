-- 📈 Window Function Analysis
-- Rank products based on total revenue.
WITH product_revenue AS (
	SELECT 
		item,
		SUM(quantity) AS total_qty_sold,
		SUM(total_spent) AS total_revenue
	FROM clean_cafe_sales_data
	GROUP BY item
)

SELECT 
	item,
	total_qty_sold,
	total_revenue,
	ROUND(total_revenue*100.00/SUM(total_revenue) OVER(),2) AS revenue_contribution_pct,
	DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_rank_by_revenue
FROM product_revenue
ORDER BY product_rank_by_revenue 
-- Rank store locations based on revenue generated.
WITH store_revenue AS (
SELECT 
	store_location ,
	SUM(quantity) AS total_qty_sold,
	SUM(total_spent) AS total_revenue
FROM  clean_cafe_sales_data
GROUP BY store_location
)
SELECT 
	store_location,
	total_qty_sold,
	total_revenue,
	ROUND(total_revenue *100.0/SUM(total_revenue) OVER(),2)revenue_pct_contribution,
	DENSE_RANK() OVER(ORDER BY total_revenue DESC ) AS store_rnk_by_revenue
FROM store_revenue
ORDER BY store_rnk_by_revenue 
-- Calculate running total revenue over time.
WITH month_wise_revenue AS (
	SELECT 
		DATE_TRUNC('Month' ,transaction_date) AS transaction_month,
		SUM(total_spent) AS total_revenue
	FROM clean_cafe_sales_data
	GROUP BY DATE_TRUNC('Month' ,transaction_date)
),
  running_revenue AS (SELECT 
		transaction_month,
		total_revenue,
		SUM(total_revenue) OVER(
		ORDER BY transaction_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		AS running_total_revenue_over_time
	FROM month_wise_revenue
)
SELECT transaction_month,
running_total_revenue_over_time,
ROUND(running_total_revenue_over_time*100.0/(
		SELECT SUM(total_revenue) FROM month_wise_revenue),2) AS over_time_revenue_running_pct
FROM running_revenue
