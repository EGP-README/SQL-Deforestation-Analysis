-- QUIZ Answers using the Parch and Posey Udacity database

--SUM and COUNT Quiz

-- Q1. Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty) poster_total
FROM orders;

-- Q2. Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) standard_total
FROM orders;

-- Q3. Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT SUM(total_amt_usd) total_dollar_amount_sales
FROM orders;

-- Q4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. This should give a dollar amount for each order in the table.
SELECT (standard_amt_usd + gloss_amt_usd) AS total_gloss_std_amt
FROM orders;

--Q5. Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both aggregation and a mathematical operator.
SELECT (SUM(standard_amt_usd) / SUM(standard_qty)) standard_per_unit_cost
FROM orders
WHERE standard_qty != 0;

-- MIN, MAX, and AVG Quiz

--Q1. When was the earliest order ever placed? You only need to return the date.
SELECT MIN(occurred_at)
FROM orders;

--Q2. Try performing the same query as in question 1 without using an aggregation function.
SELECT occurred_at min
FROM orders
ORDER BY occurred_at ASC
LIMIT 1;        

--Q3. When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at)
FROM web_events;

--Q4. Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

--Q5. Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order.
-- Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
SELECT AVG(standard_qty) AS avg_std,
       AVG(poster_qty) AS avg_poster,
       AVG(gloss_qty) AS avg_glossy,
       AVG(standard_amt_usd) AS avg_std_usd,
       AVG(poster_amt_usd) AS avg_poster_usd,
       AVG(gloss_amt_usd) AS avg_gloss_usd
FROM orders;

--Q6. Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding 
-- - what is the MEDIAN total_usd spent on all orders? Note, this is more advanced than the topics we have covered thus far to build a general solution, 
--but we can hard code a solution in the following way. Uses subquery

SELECT *
FROM (SELECT total_amt_usd
   FROM orders
   ORDER BY total_amt_usd
   LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;
       

-- GROUP BY Quiz

--Q1 Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT a.name account_name, MIN(o.occurred_at) earliest_order
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY account_name
ORDER BY earliest_order ASC
LIMIT 1;

--More efficient answer to Q1
SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

--Q2 Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.
SELECT a.name account_name, SUM(o.total_amt_usd) total_usd
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY account_name
ORDER BY total_usd DESC;

--Q3. Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.
SELECT w.channel, w.occurred_at latest_event, a.name
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
ORDER BY latest_event DESC
LIMIT 1;

--Q4 Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
SELECT channel, COUNT(channel) channel_count
FROM web_events
GROUP BY channel

--Q5 Who was the primary contact associated with the earliest web_event?
SELECT w.occurred_at, a.primary_poc
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
ORDER BY w.occurred_at ASC
LIMIT 1;

--Q6 What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
SELECT MIN(o.total_amt_usd) min_total, a.name
FROM orders o
JOIN accounts a 
    ON o.account_id = a.id
GROUP BY a.name;


--Q7 Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from the fewest reps to most reps.
SELECT r.name, COUNT(s.id) rep_count
FROM region r
JOIN sales_reps s
    ON r.id = s.region_id
GROUP BY r.name
ORDER BY rep_count ASC;


-- GROUP BY Quiz 2

--Q1 For each account, determine the average amount of each type of paper they purchased across their orders. 
--Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.
SELECT a.name, AVG(o.standard_qty) avg_std, 
       AVG(o.poster_qty) avg_poster, 
       AVG(o.gloss_qty) avg_gloss
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.name;

--Q2 For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
SELECT a.name, AVG(o.standard_amt_usd) avg_std, 
       AVG(o.poster_amt_usd) avg_poster, 
       AVG(o.gloss_amt_usd) avg_gloss
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.name;


--Q3 Determine the number of times a particular channel was used in the web_events table for each sales rep. 
--Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
--Order your table with the highest number of occurrences first.

SELECT s.name rep_name, w.channel channel,
       COUNT(channel) channel_count
FROM sales_reps s
JOIN accounts a
    ON a.sales_rep_id = s.id
JOIN web_events w
    ON a.id = w.account_id
GROUP BY rep_name, channel
ORDER BY rep_name, channel_count DESC;

--Q4 Determine the number of times a particular channel was used in the web_events table for each region. 
--Your final table should have three columns - the region name, the channel, and the number of occurrences.
-- Order your table with the highest number of occurrences first.

SELECT r.name region_name, w.channel channel,
       COUNT(*) channel_count
FROM region r
JOIN sales_reps s
    ON s.region_id = r.id
JOIN accounts a
    ON a.sales_rep_id = s.id
JOIN web_events w
    ON a.id = w.account_id
GROUP BY region_name, channel
ORDER BY region_name, channel_count DESC;


--DISTINCT Quiz

--Q1. Use DISTINCT to test if there are any accounts associated with more than one region.

SELECT DISTINCT id, name
FROM accounts;

--Comopare the resulting numebr amount

SELECT a.id as "account id", r.id as "region id", 
a.name as "account name", r.name as "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;


--Q2 Have any sales reps worked on more than one account?

--My way
SELECT s.name rep_name, COUNT(a.id) AS num_accounts
FROM sales_reps s 
JOIN accounts a
    ON s.id = a.sales_rep_id
GROUP BY rep_name;

--Theri way is to basically run the same thing and compare the row count with
SELECT DISTINCT id, name
FROM sales_reps;


--HAVING Quiz

--Q1 How many of the sales reps have more than 5 accounts that they manage?
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

--Q2. How many accounts have more than 20 orders?
SELECT a.id account_id, a.name account_name, COUNT(o.id) order_count
FROM orders o
JOIN accounts a
    ON a.id = o.account_id
GROUP BY a.id, account_name
HAVING COUNT(o.id) > 20
ORDER BY order_count;

--Q3 Which account has the most orders?
SELECT a.id account_id, a.name account_name, COUNT(o.id) order_count
FROM orders o
JOIN accounts a
    ON a.id = o.account_id
GROUP BY a.id, account_name
ORDER BY order_count DESC
LIMIT 1;

--Q4 Which accounts spent more than 30,000 usd total across all orders?
SELECT a.name, a.id, SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
  ON a.id = o.account_id
GROUP BY a.name, a.id
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent DESC;

-- Q5 Which accounts spent less than 1,000 usd total across all orders?

SELECT a.name, a.id, SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
  ON a.id = o.account_id
GROUP BY a.name, a.id
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent DESC;


-- Q6 Which account has spent the most with us?
SELECT a.name, a.id, SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
  ON a.id = o.account_id
GROUP BY a.name, a.id
ORDER BY total_spent DESC
LIMIT 1;

-- Q7 Which account has spent the least with us?
SELECT a.name, a.id, SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
  ON a.id = o.account_id
GROUP BY a.name, a.id
ORDER BY total_spent ASC
LIMIT 1;

--Q8 Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, COUNT(w.channel) chan_cnt
FROM accounts a
JOIN web_events w
  ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name
HAVING COUNT(w.channel) > 6
ORDER BY chan_cnt DESC;

--Q9 Which account used facebook most as a channel?
SELECT a.id, a.name, COUNT(w.channel) chan_cnt
FROM accounts a
JOIN web_events w
  ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name
HAVING COUNT(w.channel) > 6
ORDER BY chan_cnt DESC
LIMIT 1;

--Q10 Which channel was most frequently used by most accounts?
SELECT a.id, a.name, w.channel, COUNT(w.channel) chan_cnt
FROM accounts a
JOIN web_events w
  ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY a.name, chan_cnt DESC

--DATE Functions Quiz

--Q1 Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?
SELECT DATE_TRUNC('year', occurred_at) order_year, SUM(total_amt_usd) total_usd
FROM orders
GROUP BY order_year
ORDER BY total_usd DESC;

--Q2 Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

--Q3 Which year did Parch & Posey have the greatest sales in terms of the total number of orders? Are all years evenly represented by the dataset?
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
Again, 2016 by far h


--Q5 In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', occurred_at) order_month, SUM(gloss_amt_usd) gloss_total, a.name
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY a.name, order_month
ORDER BY gloss_total DESC;


-- CASE WHEN Quiz

--Q1 Write a query to display for each order, the account ID, the total amount of the order, and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
SELECT o.account_id, o.total_amt_usd, 
       CASE WHEN o.total_amt_usd >= 3000 THEN 'Large'
       WHEN o.total_amt_usd < 3000 THEN 'Small' END AS order_size
FROM orders o
ORDER BY o.total_amt_usd DESC;

--Q2 Write a query to display the number of orders in each of three categories, based on the total number of items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT o.account_id, o.total, 
       CASE WHEN o.total >= 2000 THEN 'At Least 2000'
       WHEN o.total < 2000 AND o.total >1000 THEN 'Between 1000 and 2000'
       ELSE 'Less than 1000' END AS order_size
FROM orders o
ORDER BY o.total_amt_usd DESC;

--Q3 We would like to understand 3 different levels of customers based on the amount associated with their purchases.
-- The top-level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
--The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. 
--Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. 
--Order with the top spending customers listed first.
SELECT a.name, o.total_amt_usd, 
       CASE WHEN o.total_amt_usd >= 200000 THEN 'At least 200000'
       WHEN o.total_amt_usd < 200000 AND o.total_amt_usd > 100000 THEN 'Between 100000 and 200000'
       ELSE '100000 or Less' END AS order_size
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name, o.total_amt_usd
ORDER BY o.total_amt_usd DESC;

--Q4 same as Q3 but only for orders 2016 and later
SELECT a.name, o.total_amt_usd, 
       CASE WHEN o.total_amt_usd >= 200000 THEN 'At least 200000'
       WHEN o.total_amt_usd < 200000 AND o.total_amt_usd > 100000 THEN 'Between 100000 and 200000'
       ELSE '100000 or Less' END AS order_size
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
WHERE occurred_at > '2015-12-31'
GROUP BY a.name, o.total_amt_usd
ORDER BY o.total_amt_usd DESC;

--Q5 We would like to identify top-performing sales reps, which are sales reps associated with more than 200 orders.
-- Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. 
--Place the top salespeople first in your final table.
SELECT s.name, COUNT(*) order_total,
  CASE WHEN COUNT(*) > 200 THEN 'top'
  ELSE 'not' END AS rating
FROM sales_reps s
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY s.name


--Q5 The previous didn't account for the middle, nor the dollar amount associated with the sales.
-- Management decides they want to see these characteristics represented as well. We would like to identify top-performing sales reps, which are sales 
--reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or
-- 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a 
--column with top, middle, or low depending on these criteria. Place the top salespeople based on the dollar amount of sales first in your final table. 
--You might see a few upset salespeople by this criteria!
SELECT s.name, COUNT(*) order_total, SUM(total_amt_usd) amount_usd,
  CASE WHEN COUNT(*) > 200 OR SUM(total_amt_usd) > 750000 THEN 'top'
  WHEN COUNT(*) > 200 OR SUM(total_amt_usd) > 500000 THEN 'mid'
  ELSE 'low' END AS rating
FROM sales_reps s
JOIN accounts a
  ON s.id = a.sales_rep_id
JOIN orders o
  ON a.id = o.account_id
GROUP BY s.name

--More subquery practice

SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);


