/*
Inner Join Questions
Provide a table for all web_events associated with the account name of Walmart. There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.
Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to the account name.
Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.
*/



--Q1
SELECT a.name, a.primary_poc poc, w.occurred_at time_stamp, w.channel
FROM accounts a
  JOIN web_events w
    ON a.id = w.account_id
WHERE a.name = 'Walmart';

--Q2
SELECT r.name region_name, s.name sales_rep_name, a.name account_name
FROM sales_reps s
  JOIN accounts a
    ON s.id = a.sales_rep_id
  JOIN region r 
    ON r.id = s.region_id
ORDER BY a.name ASC

--Q3
SELECT r.name reg_name, a.name acct_name, (o.total_amt_usd/(o.total + 0.01)) unit_price
FROM orders o
  JOIN accounts a 
    ON o.account_id = a.id
  JOIN sales_reps s
    ON a.sales_rep_id = s.id
  JOIN region r
    ON s.region_id = r.id

  --Outer Join Questions

  /*
  Provide a table that provides the region for each sales_rep along with their associated accounts. 
  This time only for the Midwest region. Your final table should include three columns: 
  the region name, the sales rep name, and the account name. 
  Sort the accounts alphabetically (A-Z) according to the account name.
  */

SELECT r.name region_name, s.name sales_rep, a.name account_name
FROM sales_reps s
JOIN region r
  ON s.region_id = r.id
JOIN accounts a
  ON s.id = a.sales_rep_id
WHERE r.name = 'Midwest'
ORDER BY a.name ASC


/*
Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a first name starting with S and in the Midwest region. 
Your final table should include three columns: the region name, the sales rep name,
and the account name. Sort the accounts alphabetically (A-Z) according to the account name.
*/

SELECT r.name region_name, s.name sales_rep, a.name account_name
FROM sales_reps s
JOIN region r
  ON s.region_id = r.id
JOIN accounts a
  ON s.id = a.sales_rep_id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name ASC;

/*
Provide a table that provides the region for each sales_rep along with their associated accounts. 
This time only for accounts where the sales rep has a last name starting with K and 
in the Midwest region. Your final table should include three columns: 
the region name, the sales rep name, and the account name. 
Sort the accounts alphabetically (A-Z) according to the account name.
*/

FROM sales_reps s
JOIN region r
  ON s.region_id = r.id
JOIN accounts a
  ON s.id = a.sales_rep_id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name ASC;

/*
Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) 
for the order. However, you should only provide the results if 
the standard order quantity exceeds 100. 
Your final table should have 3 columns: region name, account name, and unit price. 
In order to avoid a division by zero error, adding .01 to the
denominator here is helpful total_amt_usd/(total+0.01).
*/

SELECT r.name region_name, a.name account_name, (o.total_amt_usd/(o.total + 0.01)) unit_price
FROM orders o
JOIN accounts a
  ON o.account_id = a.id
JOIN sales_reps s
  ON a.sales_rep_id = s.id
JOIN region r
  ON s.region_id = r.id
WHERE o.standard_qty > 100;