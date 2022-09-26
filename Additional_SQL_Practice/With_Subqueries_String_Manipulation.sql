--Quiz WITH Statements

--Q1 Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt, COUNT(*) total_orders
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC), 
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt, total_orders
   FROM t1
   GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt, t2.total_orders
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

--Q2 For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH t1 AS (
  SELECT r.name region_name, SUM(o.total_amt_usd) total_amt, COUNT(*) total_orders
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1
   ORDER BY 3 DESC), 
t2 AS (
   SELECT region_name, total_orders, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1,2)
SELECT t1.region_name, t1.total_amt, t2.total_orders
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;


--Q3 How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1), 
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;


--Quiz LEFT and RIGHT

--Q1 In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using.
-- A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT RIGHT(website, 3) AS domain, COUNT(RIGHT(website, 3)) AS domain_count
FROM accounts
GROUP BY 1;

--Q2 There is much debate about how much the name (or even the first letter of a company name) matters. 
--Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).
SELECT LEFT(name, 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

--Q3 
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;


--Quiz: CONCAT, LEFFT, RIGTH , and SUBSTR

--Q1 Suppose the company wants to assess the performance of all the sales representatives. 
--Each sales representative is assigned to work in a particular region. To make it easier to understand for the HR team, 
--display the concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION for each sales representative.
SELECT CONCAT(s.id, '_', r.name) EMP_ID_REGION
FROM sales_reps s
JOIN region r
  ON s.region_id = r.id

  --Q2 From the accounts table, display the name of the client, the coordinate as concatenated (latitude, longitude), 
  --email id of the primary point of contact as <first letter of the primary_poc><last letter of the primary_poc>@<extracted name and domain from the website>.

  SELECT NAME, CONCAT(LAT, ', ', LONG) COORDINATE, CONCAT(LEFT(PRIMARY_POC, 1), RIGHT(PRIMARY_POC, 1), '@', SUBSTR(WEBSITE, 5)) EMAIL
FROM ACCOUNTS;

--Q3 From the web_events table, display the concatenated value of account_id, '_' , channel, '_', count of web events of the particular channel.
WITH T1 AS(
  SELECT account_id, channel, COUNT(*) AS event_count
  FROM web_events
  GROUP BY 1, 2
  ORDER BY 1)
SELECT CONCAT(T1.account_id, '_', T1.channel, '_', event_count)
FROM T1;

--CAST Quiz
WITH T1 AS
  (SELECT incidnt_num, LEFT(date, 2) AS month,       SUBSTR(date, 4, 2) AS day, SUBSTR(date, 7, 4) AS year
FROM sf_crime_data)
SELECT incidnt_num, CAST(CONCAT(year, '-', month, '-', day) AS DATE)AS crime_date
FROM T1

--CONCAT Quiz

--Q1 Each company in the accounts table wants to create an email address for each primary_poc. 
--The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.

WITH T1 AS (SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) first_name, RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name company
FROM accounts)
SELECT CONCAT(T1.first_name, '.', T1.last_name, '@', T1.company, '.com') AS email_addr
FROM T1;

--Q2 You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that
-- will work by removing all of the spaces in the account name, but otherwise, your solution should be just as in question 1. Some helpful documentation is here.
WITH T1 AS (SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) first_name, RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, REPLACE(name, ' ', '') company
FROM accounts)
SELECT CONCAT(T1.first_name, '.', T1.last_name, '@', T1.company, '.com') AS email_addr
FROM T1;

--Q3 We would also like to create an initial password, which they will change after their first log in. 
--The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), 
--the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, 
--the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.


WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

-- Window Functions Core Quiz

--Q1 Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
--Your final table should have two columns: one with the amount being added for each new row, and a second with the running total.

SELECT standard_amt_usd, SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders;

--Q2 Now, modify your query from the previous quiz to include partitions. Still create a running total of standard_amt_usd (in the orders table) over order time, but this time, '
--date truncate occurred_at by year and partition by that same year-truncated occurred_at variable.

SELECT standard_amt_usd, DATE_TRUNC('year', occurred_at) AS year_date, SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY DATE_TRUNC('year', occurred_at)) AS running_total
FROM orders;

--Rank Quiz
--Select the id, account_id, and total variable from the orders table, then create a column called total_rank that ranks this total amount of paper ordered 
--(from highest to lowest) for each account using a partition. Your final table should have these four columns.

SELECT id, account_id, total, RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank 
FROM orders