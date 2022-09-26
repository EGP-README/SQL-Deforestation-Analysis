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
1. GLOBAL SITUATION
Instructions:

Answering these questions will help you add information into the template.
Use these questions as guides to write SQL queries.
Use the output from the query to answer these questions.
*/

/*
a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
*/
SELECT f_country_name, f_year, f_area_sqkm
FROM forestation
WHERE f_country_name = 'World' AND f_year = 1990;

-- Result: World	1990	41282694.9


/*
b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”
*/
SELECT f_country_name, f_year, f_area_sqkm
FROM forestation
WHERE f_country_name = 'World' AND (f_year = 2016 OR f_year = 1990)
ORDER BY f_year ASC;

--Result: World	2016	39958245.9


/*
c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
d. What was the percent change in forest area of the world between 1990 and 2016?

Building this query to answer both questions with a window function
*/

SELECT f_country_name, f_year, f_area_sqkm, percent_forest, 
       f_area_sqkm - LAG(f_area_sqkm) OVER (ORDER BY f_area_sqkm) AS f_area_difference,
       ((LAG(percent_forest) OVER (ORDER BY percent_forest) - percent_forest) / percent_forest) * 100  AS percent_forest_diff
FROM(
SELECT f_country_name, f_year, f_area_sqkm, percent_forest
FROM forestation
WHERE f_country_name = 'World' AND (f_year = 2016 OR f_year = 1990)) sub;

--Result: 1324449	-3.22813528513264

-- Fixed to adress the difference in percentage chnage as opposed to straight percentage difference
SELECT f_country_name, f_year, f_area_sqkm, percent_forest, 
       f_area_sqkm - LAG(f_area_sqkm) OVER (ORDER BY f_area_sqkm) AS f_area_difference,
       ((LAG(f_area_sqkm) OVER (ORDER BY f_area_sqkm) - f_area_sqkm) / f_area_sqkm) * 100  AS percent_forest_diff
FROM(
SELECT f_country_name, f_year, f_area_sqkm, percent_forest
FROM forestation
WHERE f_country_name = 'World' AND (f_year = 2016 OR f_year = 1990)) sub;


/*
e. If you compare the amount of forest area lost between 1990 and 2016, to which countrys total area in 2016 is it closest to?
*/
SELECT f_country_name, l_total_area_sqkm, l_total_area_sq_mi
FROM forestation 
WHERE l_total_area_sqkm <= 1324449
ORDER BY l_total_area_sqkm DESC
LIMIT 1;

-- Result: Peru	1279999.9891	494208.49