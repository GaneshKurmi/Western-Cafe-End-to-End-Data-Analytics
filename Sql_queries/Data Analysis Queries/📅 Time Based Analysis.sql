-- 📅 Time-Based Analysis
-- What are the daily sales trends?
WITH revenue_change AS (
	SELECT transaction_date , 
	COUNT(*) AS total_transaction,
	SUM(quantity) AS total_qty_sold,
	SUM(total_spent) AS total_revenue,
	LAG(SUM(total_spent)) OVER(ORDER BY transaction_date ) AS previous_day_revenue,
	SUM(total_spent) - LAG(SUM(total_spent)) OVER(ORDER BY transaction_date ) AS revenue_change
	FROM  clean_cafe_sales_data
GROUP BY transaction_date),
revenue_growth AS (
SELECT 
	*,
ROUND(revenue_change*100.0/NULLIF(previous_day_revenue,0),2) AS revenue_growth_pct
FROM revenue_change
)
SELECT 
	transaction_date , 
	total_transaction,
	total_qty_sold,
	total_revenue,
	previous_day_revenue,
	revenue_change,
	revenue_growth_pct
FROM revenue_growth
ORDER BY transaction_date
-- What are the monthly sales trends?
WITH month_wise_revenue AS (
				SELECT 
					TO_CHAR(transaction_date,'Mon') AS transaction_month ,
					EXTRACT(MONTH FROM transaction_date) AS transaction_month_num, 
					COUNT(*) AS total_transaction,
					SUM(quantity) AS total_qty_sold,
					SUM(total_spent) AS total_revenue
				FROM  clean_cafe_sales_data
			    GROUP BY EXTRACT(MONTH FROM transaction_date) , TO_CHAR(transaction_date,'Mon')),
revenue_change AS (
				SELECT 
					* ,
					LAG(total_revenue) OVER(ORDER BY transaction_month_num ) AS previous_month_revenue,
					total_revenue - LAG(total_revenue) OVER(ORDER BY transaction_month_num ) AS revenue_change
				FROM month_wise_revenue),

revenue_growth AS (
				SELECT 
					*,
				    ROUND(revenue_change*100.0/NULLIF(previous_month_revenue,0),2) AS revenue_growth_pct
				FROM revenue_change
)
SELECT 
	transaction_month , 
	total_transaction,
	total_qty_sold,
	total_revenue,
	previous_month_revenue,
	revenue_change,
	revenue_growth_pct
FROM revenue_growth
ORDER BY transaction_month_num
-- Which day recorded the highest revenue?
WITH revenue AS (
	SELECT 
		transaction_date,
		SUM(total_spent) AS total_revenue
	FROM clean_cafe_sales_data
	WHERE transaction_date IS NOT NULL
	GROUP BY transaction_date),
revenue_ranking AS (
	SELECT 
	*,
	DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rev_rnk
	FROM revenue
    )
SELECT * FROM revenue_ranking
WHERE rev_rnk =1
-- Which day recorded the highest number of transactions?
WITH transaction_data AS (
	SELECT 
		transaction_date,
		COUNT(*) AS total_transaction
	FROM clean_cafe_sales_data
	WHERE transaction_date IS NOT NULL
	GROUP BY transaction_date),
transaction_ranking AS (
	SELECT 
	*,
	DENSE_RANK() OVER(ORDER BY total_transaction DESC) AS transaction_rnk
	FROM transaction_data
    )
SELECT * FROM transaction_ranking
WHERE transaction_rnk =1
-- What is the average daily revenue?
SELECT 
	ROUND(AVG(daily_revenue),2) AS avg_daily_revenue
FROM (
	SELECT 
		transaction_date , 
		SUM(total_spent) AS daily_revenue 
	FROM  clean_cafe_sales_data 
	WHERE transaction_date IS NOT NULL
    GROUP BY transaction_date ) t

-- Which month generated the highest revenue?
SELECT
	TO_CHAR(transaction_date,'Mon''yy') AS transaction_month,
	SUM(quantity) AS total_qty_sold,
	SUM(total_spent) AS total_revenue
FROM clean_cafe_sales_data
GROUP BY TO_CHAR(transaction_date,'Mon''yy')
ORDER BY total_revenue DESC , 
total_qty_sold DESC
LIMIT 1
-- Are there any noticeable sales peaks or dips over time?
WITH revenue_view AS (
	SELECT
		DATE_TRUNC('Month', transaction_date) AS sales_month,
		SUM(quantity) AS total_qty_sold,
		SUM(total_spent) AS total_revenue
    FROM clean_cafe_sales_data
    WHERE transaction_date IS NOT NULL
    GROUP BY 
		DATE_TRUNC('Month', transaction_date)
)
	SELECT *,
		LAG(total_revenue) OVER(ORDER BY sales_month ) AS previous_month_revenue,
		ROUND((total_revenue - LAG(total_revenue) OVER(ORDER BY sales_month ))*100.0
		/NULLIF(LAG(total_revenue) OVER(ORDER BY sales_month ),0),2) AS mom_revenue_growth
		FROM revenue_view
	ORDER BY sales_month
