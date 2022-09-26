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
2. REGIONAL OUTLOOK
Instructions:

Answering these questions will help you add information into the template.
Use these questions as guides to write SQL queries.
Use the output from the query to answer these questions.

Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
Based on the table you created, ....
*/

SELECT r_region, f_year, ROUND(CAST(SUM(f_area_sqkm) / SUM(l_total_area_sqkm) * 100 AS NUMERIC), 2) AS regional_percent_forest
FROM forestation
WHERE f_year = 2016 OR f_year = 1990
GROUP BY r_region, f_year
ORDER BY f_year, r_region ASC;