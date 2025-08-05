 -- Customer Demographics Analysis
 -- 1.Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
 SELECT COUNT(*) AS total_transaction , gender , category
 FROM retail_sale
 GROUP BY 2 , 3
 ORDER BY 1 DESC;
-- 2. Gender-based purchasing patterns (Male vs Female) Which category are most bought by male and female customer
WITH top_pur_pattern AS
( 
SELECT gender , category ,SUM(quantiy) AS total ,
RANK() OVER(PARTITION BY gender ORDER BY SUM(quantiy) DESC ) AS top_choice
FROM retail_sale
GROUP BY gender , category
ORDER BY 3 DESC
)
SELECT *
FROM top_pur_pattern
WHERE top_choice = 1; -- Clothing is the popular category among male and female
-- 3. Age group analysis 
SELECT 
CASE
WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
END AS age_group ,
 COUNT(customer_id) AS total 
FROM retail_sale
GROUP BY 1
ORDER BY 2 DESC;

-- 4.Which month has the most customer over the year filtering by year
SELECT MONTHNAME(sale_date) ,
COUNT(customer_id) AS num_of_cus
FROM retail_sale
WHERE YEAR(sale_date) = '2023'
GROUP BY 1
ORDER BY 2 DESC;
-- Sales analysis
-- 5.Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT *
FROM retail_sale
WHERE sale_date = '2022-11-05';
-- 6.Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022:
SELECT *
FROM retail_sale 
WHERE category = 'Clothing'
 AND
 DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
 AND 
 quantiy > 3;
 
 -- 7.Write a SQL query to calculate the total sales (total_sale) for each category.:
 SELECT category , SUM(total_sale) 
 FROM retail_sale
 GROUP BY category;
 
 -- 8.Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:alter
 SELECT AVG(age) AS avage 
 FROM retail_sale
 WHERE category = 'Beauty';
 
 -- 9.a Write a SQL query to calculate the average sale for each month. 
 SELECT  ROUND(AVG(total_sale),2) , MONTHNAME(sale_date) , YEAR(sale_date)
 FROM retail_sale
 GROUP BY 2 ,3;
 -- 9.b Find out best selling month in each year
 WITH best_selling_month AS
 (
 SELECT  ROUND(AVG(total_sale),2) AS avg_sale , MONTHNAME(sale_date) , YEAR(sale_date) ,
 RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY ROUND(AVG(total_sale),2) DESC) AS rank_best
 FROM retail_sale
 GROUP BY 2 ,3
 )
 SELECT *
 FROM best_selling_month
 WHERE rank_best = 1;
 
 -- 10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
 
 SELECT COUNT(*) AS num_order ,
 EXTRACT(HOUR FROM sale_time),
 CASE
 WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
 WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
 ELSE 'Evening'
 END AS shift
 FROM retail_sale 
 GROUP BY 2
 ORDER BY 1 DESC;
-- 11.Which quarter has the highest revenue
SELECT QUARTER(sale_date) AS quarterly ,
SUM(total_sale) AS total_revenue
FROM retail_sale
GROUP BY 1
ORDER BY 2 DESC;
-- 12 Determine the month on month increase or decrease on sales With percentage increase or decrease
SELECT MONTH(sale_date) ,
SUM(total_sale) AS monthly_revenue ,
SUM(total_sale)-LAG(SUM(total_sale),1) OVER(ORDER BY MONTH(sale_date) ASC) AS previous_month_revenue ,
(SUM(total_sale)-LAG(SUM(total_sale),1) OVER(ORDER BY MONTH(sale_date) ASC)) /
(LAG(SUM(total_sale),1) OVER(ORDER BY MONTH(sale_date) ASC)) *100 AS per_in_dec
FROM retail_sale
WHERE YEAR(sale_date) = '2023'
GROUP BY 1
ORDER BY 1;
 -- 13 Sales analysis on weekday and weekend on specfic month and year
 SELECT
 CASE WHEN DAYOFWEEK(sale_date) IN (1,7) THEN 'Weekend'
 ELSE 'Weekday'
 END AS day_of_week, 
 SUM(total_sale)
 FROM retail_sale
 WHERE MONTH(sale_date) = 2
 AND YEAR(sale_date) ='2023'
 GROUP BY 1;
 
 -- Profit Analysis
 -- 14 Make a view for sales from the original table showing profit as a column.Then calculate running total 
 CREATE VIEW sales AS 
 SELECT * , (total_sale - (pur_cost*quantiy)) AS gross_profit
 FROM retail_sale;
 -- Calculating running total 
 SELECT * , 
 SUM(total_sale) OVER(ORDER BY sale_date ASC , sale_time) AS running_total
 FROM sales;
  -- 15 Calcuating profit on each category and find which one has the highest profit category over the year 
 WITH higest_profitable_category AS
 (
 SELECT YEAR(sale_date) AS year , CONCAT('$',SUM(gross_profit)) AS profit , category , 
 RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY CONCAT('$',SUM(gross_profit)) DESC ) AS num_1
 FROM sales
 GROUP BY 1 ,3
 )
 SELECT *
 FROM higest_profitable_category;
 -- WHERE num_1 = 1;

