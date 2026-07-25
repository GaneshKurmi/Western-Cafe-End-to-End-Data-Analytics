--Create uncleaned RAW table structure
CREATE TABLE cafe_sales_raw (
transaction_id VARCHAR(20),
item VARCHAR(20),
quantity VARCHAR(20),
price_per_unit VARCHAR(20),
total_spent VARCHAR(20),
payment_method VARCHAR(20),
store_location VARCHAR(20),
transaction_date VARCHAR(20)
);

SELECT * FROM cafe_sales_raw

SELECT COUNT(*) FROM cafe_sales_raw

--Checking Duplicate Value
SELECT * FROM (SELECT * , 
ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id ) AS row_num
FROM cafe_sales_raw) t
WHERE row_num >1

SELECT DISTINCT(item)  FROM cafe_sales_raw

-- Data Cleaning: Replace missing and invalid item values with 'unknown'
UPDATE cafe_sales_raw
SET item = 'unknown'
WHERE item IN('ERROR','UNKNOWN') 
		OR item IS NULL OR item ='';

-- Check if transaction id is containing any missing value or null or other possibilties
SELECT * FROM cafe_sales_raw
WHERE transaction_id IS NULL 
	OR TRIM(transaction_id) ='';

--Checking if transaction_id is different than its sequence
SELECT * FROM cafe_sales_raw
WHERE transaction_id NOT LIKE 'TXN_%';

SELECT DISTINCT(quantity) FROM cafe_sales_raw

-- Data Quality Fix: Impute missing and erroneous quantity values
UPDATE cafe_sales_raw
SET quantity = 0
WHERE quantity IS NULL 
OR quantity IN('UNKNOWN' , 'ERROR') 
OR TRIM(quantity) = '';

SELECT DISTINCT(item),price_per_unit FROM cafe_sales_raw

-- Data Quality Fix: Impute missing and erroneous price_per_unit values
WITH per_item_price AS (
SELECT item, 
	MAX(price_per_unit) AS valid_price_per_unit
	FROM cafe_sales_raw 
	WHERE price_per_unit IS NOT NULL 
	AND price_per_unit NOT IN ('ERROR' ,'UNKNOWN') 
GROUP BY  item
) 
	UPDATE cafe_sales_raw c
	SET price_per_unit = p.valid_price_per_unit
	FROM per_item_price p
	WHERE c.item = p.item
  	AND (
        c.price_per_unit IS NULL
        OR c.price_per_unit IN ('ERROR','UNKNOWN')
        OR TRIM(c.price_per_unit) = ''
      );

-- Data Quality Fix: Recalculate missing and invalid total_spent values using quantity × price_per_unit
UPDATE cafe_sales_raw
SET total_spent = CAST(quantity AS NUMERIC) * CAST(price_per_unit AS NUMERIC)
WHERE total_spent IS NULL 
OR total_spent IN ('UNKNOWN' ,'ERROR')
OR TRIM(total_spent) ='';

--Data Cleaning: Standardize Payment Method Values

UPDATE cafe_sales_raw
SET payment_method ='Cash'
WHERE payment_method IS NULL OR
payment_method IN ('UNKNOWN' ,'ERROR') OR
TRIM(payment_method) = '';


SELECT * FROM cafe_sales_raw
SELECT transaction_date , COUNT(*) FROM cafe_sales_raw
WHERE transaction_date IS NULL OR transaction_date IN('N/A' ,'UNKNOWN' ,'ERROR') OR TRIM(transaction_date) =''
GROUP BY transaction_date

--Clean and standardize the store_location column by handling NULL, blank, UNKNOWN, and ERROR values.
UPDATE cafe_sales_raw
SET store_location = 'Others'
WHERE store_location IS NULL OR
store_location IN ('UNKNOWN','ERROR') OR
TRIM(store_location) = ''; 

--Clean and standardize the transaction_date column by handling NULL, blank, UNKNOWN, and ERROR values.
UPDATE cafe_sales_raw
SET transaction_date = NULL
WHERE transaction_date IS NULL OR transaction_date IN('N/A' ,'UNKNOWN' ,'ERROR') OR TRIM(transaction_date) =''

--Create final clean_cafe_sales_data
CREATE TABLE clean_cafe_sales_data AS 
SELECT 
	transaction_id ,
	item,
	CAST(quantity AS INT) AS quantity,
	CAST(price_per_unit AS NUMERIC(10,2)) AS price_per_unit,
	CAST(total_spent AS NUMERIC(10,2)) AS total_spent,
	payment_method,
	store_location,
	CASE
		WHEN transaction_date IS NULL THEN NULL
		ELSE TO_DATE(transaction_date ,'MM/DD/YYYY')
		END AS transaction_date
	FROM cafe_sales_raw

--Checking final table after cleaning
SELECT * FROM clean_cafe_sales_data



