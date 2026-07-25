-- 💳 Payment Method Analysis
-- Which payment method is used most frequently?
SELECT 
 	   payment_method,
	   total_transaction,
	   total_contribution_pct,
	   transaction_rnk
FROM ( 
SELECT payment_method, COUNT(*) AS total_transaction , 
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) AS total_contribution_pct ,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC ) AS transaction_rnk
FROM clean_cafe_sales_data
GROUP BY payment_method 
) t
WHERE transaction_rnk =1
-- Which payment method generates the highest revenue?
SELECT 
 	   payment_method,
	   total_revenue,
	   total_contribution_pct,
	   transaction_rnk
FROM ( 
SELECT payment_method, SUM(total_spent) AS total_revenue , 
ROUND(SUM(total_spent)*100.0/SUM(SUM(total_spent)) OVER(),2) AS total_contribution_pct ,
DENSE_RANK() OVER(ORDER BY SUM(total_spent) DESC ) AS transaction_rnk
FROM clean_cafe_sales_data
GROUP BY payment_method 
) t
WHERE transaction_rnk =1
-- What is the average transaction value by payment method? 
SELECT 
	payment_method, 
	ROUND(AVG(total_spent),2) AS average_transaction_value 
FROM clean_cafe_sales_data
GROUP BY payment_method 
-- What percentage of transactions are made through each payment method?
SELECT 
 	   payment_method,
	   total_transaction,
	   total_contribution_pct,
	   transaction_rnk
FROM ( 
SELECT payment_method, COUNT(*) AS total_transaction , 
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) AS total_contribution_pct ,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC ) AS transaction_rnk
FROM clean_cafe_sales_data
GROUP BY payment_method 
) t
-- Do customers spend more when using certain payment methods?
SELECT 
	payment_method,
	ROUND(AVG(total_spent),2) AS avg_transaction_value,
	DENSE_RANK() OVER(ORDER BY AVG(total_spent) DESC)
FROM clean_cafe_sales_data
GROUP BY payment_method 
