-- Adjust 'rating' column to DECIMAL(3,1) to accommodate values with 1 digit before the decimal point and 1 digit after.
ALTER TABLE amazon
MODIFY COLUMN `rating` float;

--  'Payment' column d_type change into varchar
ALTER TABLE amazon
MODIFY COLUMN `Payment` varchar(50);

-- Remove precision specification from FLOAT columns to address the warning.
ALTER TABLE amazon
MODIFY COLUMN `Tax 5%` FLOAT;
ALTER TABLE amazon
MODIFY COLUMN `gross margin percentage` FLOAT;

-- Other column modifications remain unchanged.
ALTER TABLE amazon
MODIFY COLUMN `Invoice ID` VARCHAR(30),
MODIFY COLUMN `branch` VARCHAR(5),
MODIFY COLUMN `City` VARCHAR(30),
MODIFY COLUMN `Customer type` VARCHAR(30),
MODIFY COLUMN `Gender` VARCHAR(10),
MODIFY COLUMN `Product line` VARCHAR(100),
MODIFY COLUMN `Unit price` DECIMAL(10,2),
MODIFY COLUMN `Quantity` INT,
MODIFY COLUMN `Total` DECIMAL(10,2),
MODIFY COLUMN `Date` DATE,
MODIFY COLUMN `Time` TIMESTAMP,
MODIFY COLUMN `cogs` DECIMAL(10,2),
MODIFY COLUMN `gross income` DECIMAL(10,2);

-- Check the data types of columns in the 'amazon' table
-- SELECT COLUMN_NAME, DATA_TYPE
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'amazon';


-- finding NULL values
SELECT *
FROM amazon
WHERE 'rating' IS NULL;    -- check all columns sequencially
						   --  no NULL values here
                           
-- find duplicate values
SELECT 'rating', COUNT(*)
FROM amazon
GROUP BY 'rating'
HAVING COUNT(*) > 1;     -- check all columns sequencially
						-- also here doesn't have duplicate values

-- add column 'time_of_day'
ALTER TABLE amazon
ADD COLUMN `time_of_day` VARCHAR(20);


-- update the "column values "   'time_of_day' column with appropriate values using CASE expressions
UPDATE amazon
SET `time_of_day` = CASE
WHEN HOUR(`Time`) >= 6 AND HOUR(`Time`) < 12 THEN 'Morning'
WHEN HOUR(`Time`) >= 12 AND HOUR(`Time`) < 18 THEN 'Afternoon'
ELSE 'Evening'
END;

-- check column 'time_of_day' exist or not
-- select* from amazon;



-- once check start date and end date in my table
-- SELECT 
--     MIN(Date) AS starting_date,
--     MAX(Date) AS ending_date
-- FROM amazon;


-- add column 'day_name' from the amazon table
alter table amazon
add column day_name varchar(20);


-- Update the new column with the day of the week
update amazon
set day_name = CASE 
WHEN DAYOFWEEK(`date`) = 1 THEN 'Sun'
WHEN DAYOFWEEK(`date`) = 2 THEN 'Mon'
WHEN DAYOFWEEK(`date`) = 3 THEN 'Tue'
WHEN DAYOFWEEK(`date`) = 4 THEN 'Wed'
WHEN DAYOFWEEK(`date`) = 5 THEN 'Thu'
WHEN DAYOFWEEK(`date`) = 6 THEN 'Fri'
WHEN DAYOFWEEK(`date`) = 7 THEN 'Sat'
END
WHERE (MONTH(`date`) = 1 AND DAY(`date`) = 31)
   OR (MONTH(`date`) = 3 AND DAY(`date`) = 3)
   OR (YEAR(`date`) = 2019);




-- Add a new column named 'monthname' to your_table
ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(20);

-- Update the 'monthname' column with the month names extracted from the 'Date' column
UPDATE amazon
SET monthname = CASE
    WHEN MONTH(`Date`) = 1 THEN 'Jan'
    WHEN MONTH(`Date`) = 2 THEN 'Feb'
    WHEN MONTH(`Date`) = 3 THEN 'Mar'
    ELSE 'Unknown'
END
WHERE YEAR(`Date`) = 2019
AND MONTH(`Date`) IN (1, 2, 3);




-- alter table amazon
-- drop column time_of_day;

-- alter table amazon
-- drop column day_name;

-- alter table amazon
-- drop column monthnameamazon

-- select monthname from amazon;

-- select* from amazon;
--
--
--


-- 1.What is the count of distinct cities in the dataset
select count(distinct city) from amazon;


-- 2.For each branch, what is the corresponding city?
select  distinct branch,city as branch_wise_city from amazon;


-- 3.What is the count of distinct product lines in the dataset?
select count(distinct 'product line') as distinct_product_lines from amazon;


-- 4.Which payment method occurs most frequently
-- A.
select max(payment) from amazon;

-- B.
select  max(payment),count(*) as most_frequent_payment from amazon
group by payment order by most_frequent_payment desc  limit 1;


-- 5.Which product line has the highest sales?
select 'product line', sum(total) as sum_of_totalsales
from amazon
group by 'product line'
order by  sum_of_totalsales desc
limit 1;


-- 6.How much revenue is generated each month?
select  monthname,sum(total) as month_wise_revinue
from amazon
group by monthname
order by month_wise_revinue desc;


-- 7.In which month did the cost of goods sold reach its peak?
SELECT monthname, sum(cogs) as total_cogs  
from amazon
group by monthname
order by total_cogs desc
limit 1;


-- 8. Which product line generated the highest revenue?
select 'product line', sum(total) as highist_productline_revenue 
from amazon
group by 'product line'
order by highist_productline_revenue desc
limit 1; 


-- 9.In which city was the highest revenue recorded?
select city, sum(total) as highist_city_revenue
from amazon 
group by city
order by highist_city_revenue desc
limit 1;


-- 10.Which product line incurred the highest Value Added Tax?
select `product line`,sum(`tax 5%`) as highest_tax
from amazon 
group by `product line`
order by `highest_tax` desc
limit 1;


-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select *,
case 
when total > avg_sales then 'good'
else 'bad'
end as sales_status
from(select `product line`, total, avg(total) over() as avg_sales
from amazon) as seperatetable;

-- 12.Identify the branch that exceeded the average number of products sold.
select branch,
total_products_sold,
case when total_products_sold > avg_products_sold then 'Exceeded'
else 'Not Exceeded' end  as sales_status
from (
select branch,
COUNT(*) AS total_products_sold,
AVG(COUNT(*)) over() as avg_products_sold
FROM amazon
group by branch) as subquery;


-- 13.Which product line is most frequently associated with each gender?
WITH RankedProductLines AS (
SELECT Gender,
`Product line`,
ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY COUNT(*) DESC) as rnk
FROM amazon
GROUP BY Gender, `Product line`
)
SELECT Gender, `Product line`
FROM RankedProductLines
WHERE rnk = 1;


-- 14.Calculate the average rating for each product line.
select `product line`,avg(rating) as product_avg_rate
from amazon
group by `Product line`;


-- 15.Count the sales occurrences for each time of day on every weekday.
select time_of_day,day_name,
count(total) as count_sales
from amazon
group by time_of_day,day_name;


-- 16.Identify the customer type contributing the highest revenue.
select `customer type`,sum(total) as highest_revinue
from amazon
group by `customer type`
order by highest_revinue desc
limit 1;


-- 17.Determine the city with the highest VAT percentage.
select city,max(`tax 5%`) as highest_cityvat_persentage
from amazon
group by city
order by highest_vat_persentage desc
limit 1;


-- 18.Identify the customer type with the highest VAT payments.
select `customer type`,max(`tax 5%`) as highest_customerVAT_percent
from amazon
group by `customer type`
order by highest_customerVAT_percent desc
limit 1;


-- 19.What is the count of distinct customer types in the dataset?
select count(distinct `customer type`) as count_dist_cust
from amazon;


-- 20.What is the count of distinct payment methods in the dataset?
select count(distinct payment) as dist_payment_method
from amazon;


-- 21.Which customer type occurs most frequently?
SELECT max(`customer type`) AS most_frequently
FROM amazon
GROUP BY `Customer type`
ORDER BY most_frequently DESC
LIMIT 1;



-- 22.Identify the customer type with the highest purchase frequency.
SELECT `Customer type`, count(*) AS high_frequency
FROM amazon
GROUP BY `Customer type`
ORDER BY high_frequency DESC
LIMIT 1;


-- 23.Determine the predominant gender among customers.
select gender,count(gender) as predo_gender
from amazon
group by gender
order by   predo_gender desc
limit 1;

-- 24.Examine the distribution of genders within each branch.
select branch,gender,count(*) as gender_distribution
from amazon
group by branch,gender
order by gender_distribution desc;


-- 25.Identify the time of day when customers provide the most ratings.
select time_of_day,rating,count(*) as most_rating
from amazon
group by time_of_day,rating
order by most_rating desc
limit 1;


-- 26.Determine the time of day with the highest customer ratings for each branch.
select time_of_day,rating,count(rating) as timewise_highest_ratings
from amazon 
group by time_of_day,rating
order by timewise_highest_ratings;


-- 27.Identify the day of the week with the highest average ratings.
select day_name,rating,count(*) as day_wise_ratings
from amazon
group by day_name,rating
order by day_wise_ratings asc;

-- 28.Determine the day of the week with the highest average ratings for each branch.
select branch,day_name,avg(rating) as high_avg_rating
from amazon
group by branch,day_name
order by high_avg_rating;



select * from amazon;
