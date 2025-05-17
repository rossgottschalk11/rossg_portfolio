-- US Household Income Project (Data Cleaning and EDA)

SELECT * 
FROM us_project.us_household_income_statistics
;

SELECT * 
FROM us_project.us_household_income
;

ALTER TABLE  us_project.us_household_income_statistics
RENAME COLUMN `ï»¿id` to `id`;

SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING count(id) > 1
;

-- IDENTIFY THE ROW IDs OF THE DUPLICATES
SELECT *
FROM( 
	SELECT row_id, id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) rownum
	FROM us_household_income
    ) dupes
    WHERE rownum>1
;

-- DELETE THE ROW IDs OF THE DUPLICATES IDENTIFIED
DELETE FROM us_household_income
WHERE row_id IN
	(SELECT row_id
		FROM( 
			SELECT row_id, id,
			ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) rownum
			FROM us_household_income
			) dupes
		WHERE rownum>1)
        ;
            
-- IDENTIFY AND CLEAN UP DATA INCONSISTENCIES WITH STATE NAME
SELECT State_Name, COUNT(State_Name)
FROM us_household_income
GROUP BY State_Name
;
UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia' 
;
UPDATE us_project.us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama' 
;

-- UPDATE MISSING DATA
UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City =  'Vinemont'
;

SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type
;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

-- ----------------------------------------------------------------------------------------------------------------------------
-- EXPLORATORY DATA ANALYSIS

-- TOP 10 STATES BY AREA OF WATER
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;

SELECT *
FROM us_household_income inc
INNER JOIN us_household_income_statistics stats
ON inc.id = stats.id
WHERE mean <> 0
;

-- LOWEST AVERAGE INCOME STATES
SELECT inc.State_Name,ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income inc
INNER JOIN us_household_income_statistics stats
ON inc.id = stats.id
WHERE mean <> 0
GROUP BY State_Name
ORDER BY 2
LIMIT 10
;

-- HIGHEST AVERAGE INCOME STATES
SELECT inc.State_Name,ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income inc
INNER JOIN us_household_income_statistics stats
ON inc.id = stats.id
WHERE mean <> 0
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;

-- HIGHEST AVERAGE INCOME COUNTIES
SELECT County, inc.State_Name, ROUND(AVG(Mean),1)
FROM us_household_income inc
INNER JOIN us_household_income_statistics stats
ON inc.id = stats.id
WHERE mean <> 0
GROUP BY County, inc.State_Name
ORDER BY ROUND(AVG(Mean),1) DESC
;

-- HIGHEST AVERAGE INCOMES BY CITY
SELECT inc.State_Name, City, ROUND(AVG(Mean),1)
FROM us_household_income inc
INNER JOIN us_household_income_statistics stats
ON inc.id = stats.id
GROUP BY inc.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC

