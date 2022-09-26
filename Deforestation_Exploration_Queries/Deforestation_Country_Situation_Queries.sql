--Evan Plumley
--25SEP2022
--Udacity SQL Deforestation Project Appendix

/*
Steps to Complete
Create a View called “forestation” by joining all three tables - forest_area, land_area and regions in the workspace.
The forest_area and land_area tables join on both country_code AND year.
The regions table joins these based on only country_code.
In the forestation View, include the following:

All of the columns of the origin tables
A new column that provides the percent of the land area that is designated as forest.
Keep in mind that the column forest_area_sqkm in the forest_area table and the land_area_sqmi in the land_area table are in different units (square kilometers and square miles, respectively), so an adjustment will need to be made in the calculation you write (1 sq mi = 2.59 sq km).
*/

CREATE VIEW forestation
AS
SELECT f.country_code f_country_code, f.country_name f_country_name,
       r.region r_region, f.year f_year, r.income_group r_income_group, 
       f.forest_area_sqkm f_area_sqkm, (f.forest_area_sqkm / 2.59) AS f_area_sq_mi, 
       l.total_area_sq_mi l_total_area_sq_mi, (l.total_area_sq_mi * 2.59) AS l_total_area_sqkm,
      (f.forest_area_sqkm / (l.total_area_sq_mi * 2.59)) * 100 AS percent_forest
FROM forest_area f
JOIN land_area l
    ON f.country_code = l.country_code 
    AND f.year = l.year
JOIN regions r
    ON f.country_code = r.country_code;



/*
3. COUNTRY-LEVEL DETAIL
Instructions:

Answering these questions will help you add information to the template.
Use these questions as guides to write SQL queries.
Use the output from the query to answer these questions.
*/

/*
a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

These queries also answered the success stories section
*/

SELECT f1.f_country_name AS f1_country_name,
       f1.r_region AS region,
       (f1.f_area_sqkm - f2.f_area_sqkm) AS absolute_area_change
FROM forestation f1
JOIN forestation f2 --SELF JOIN
    ON f1.f_country_name = f2.f_country_name
    AND f1.f_year = 1990 -- Self Join Parameters
    AND f2.f_year = 2016 
WHERE (f1.f_area_sqkm IS NOT NULL) AND (f2.f_area_sqkm IS NOT NULL)
ORDER BY absolute_area_change DESC;


/*
b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
*/


SELECT f1.f_country_name AS f1_country_name,
       f1.r_region AS region,
       ROUND(CAST((1 - (f2.percent_forest/f1.percent_forest)) * 100 AS NUMERIC), 2) AS percent_area_change
FROM forestation f1
JOIN forestation f2 --SELF JOIN
    ON f1.f_country_name = f2.f_country_name
    AND f1.f_year = 1990 
    AND f2.f_year = 2016 
WHERE (f1.percent_forest IS NOT NULL) AND (f2.percent_forest IS NOT NULL)
ORDER BY percent_area_change DESC;


/*
c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
*/

-- WITH subquery to gether all the quartiles
WITH t1 AS (SELECT f_country_name, f_year, percent_forest, 
        CASE WHEN percent_forest <= 25 THEN 1 
            WHEN percent_forest <= 50 AND percent_forest > 25 THEN 2
            WHEN percent_forest <= 75 AND percent_forest > 50 THEN 3
            WHEN percent_forest > 75 THEN 4 END AS forestation_quartile
        FROM forestation
        WHERE f_year = 2016 AND percent_forest IS NOT NULL 
            AND f_country_name != 'World' 
        ORDER BY forestation_quartile)
-- Main/Outer query to group the quartriles and count totals countries
SELECT COUNT(*) AS number_of_countries, forestation_quartile
FROM t1
GROUP BY forestation_quartile
ORDER BY forestation_quartile DESC;


/*
d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
*/

-- WITH subquery to gether all the quartiles
WITH t1 AS (SELECT f_country_name, r_region, f_year, percent_forest, 
        CASE WHEN percent_forest <= 25 THEN 1 
            WHEN percent_forest <= 50 AND percent_forest > 25 THEN 2
            WHEN percent_forest <= 75 AND percent_forest > 50 THEN 3
            WHEN percent_forest > 75 THEN 4 END AS forestation_quartile
        FROM forestation
        WHERE f_year = 2016 AND percent_forest IS NOT NULL
        ORDER BY forestation_quartile)
-- Main/Outer query to list top quartile countries
SELECT f_country_name, r_region, ROUND(CAST(percent_forest AS NUMERIC), 2) percent_forest_rounded, 
       forestation_quartile
FROM t1
WHERE forestation_quartile = 4
ORDER BY percent_forest DESC;


/*
e. How many countries had a percent forestation higher than the United States in 2016?
*/

SELECT f_country_name, ROUND(CAST(percent_forest AS NUMERIC), 2) AS percent_forest_us
FROM forestation
WHERE f_country_name LIKE '%United States%' AND f_year = 2016

--From this query we know that the US percent of forestation in 2016 was 33.93%

--Get one-hot count of all countries who have a higher percent than the US in 2016
WITH t1 AS (SELECT f_country_name, ROUND(CAST(percent_forest AS NUMERIC), 2) AS percent_forest_rounded, 
            CASE WHEN ROUND(CAST(percent_forest AS NUMERIC), 2) > 33.93 THEN 1
            ELSE 0 END AS is_higher_than_us
            FROM forestation
            WHERE f_year = 2016 AND percent_forest IS NOT NULL)
-- SUM all the one-hot vlaues for total count of countries that have a higehr percent
SELECT SUM(t1.is_higher_than_us)
FROM t1

--result: 94 countries have a higher forestation percentage than the us
