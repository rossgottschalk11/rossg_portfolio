-- WORLD LIFE EXPECTANCY PROJECT (DATA CLEANING)

SELECT * 
FROM world_life_expectancy
;

-- IDENTIFY THE ROW NUMBER OF ANY DUPLICATES FOR COUNTRY + YEAR COMBO. 
SELECT *
FROM (
	SELECT Row_ID, CONCAT(Country, Year),
	ROW_NUMBER() OVER(Partition By CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy)
    AS Row_Table
WHERE Row_Num > 1
;

-- DELETE THE ROW IDs OF THE DUPLICATES IDENTIFIED
DELETE FROM world_life_expectancy
WHERE Row_ID IN 
	(SELECT Row_ID FROM 
		(SELECT Row_ID, CONCAT(Country, Year),
		ROW_NUMBER() OVER(Partition By CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
		FROM world_life_expectancy
        ) AS Row_Table
		WHERE Row_Num > 1
	);

-- IDENTIFY ROWS WHERE STATUS IS BLANK
SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;    


-- SELF JOIN TABLE TO IDENTIFY WHERE COUNTRY STATUS IS BLANK IN TABLE1
-- THEN, IDENTIFY THE SAME COUNTRY IN TABLE2 WHERE THE STATUS IS NOT BLANK AND STATUS IS 'DEVELOPING'
-- UPDATE THE BLANK IN TABLE1 TO 'DEVELOPING'
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2. status <> ''
AND t2.Status = 'Developing'
;   

-- NOW DOING THE SAME THING FOR 'DEVELOPED' COUNTRIES
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2. status <> ''
AND t2.Status = 'Developed'
;   


-- IDENTIFY BLANK VALUES IN LIFE EXPECTANCY COLUMNS
SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;


-- USING SELF JOINS, BUILD OUT OF LOGIC TO:
-- FIND AVERAGE LIFE EXPECTANCY FOR THE COUNTRY IN THE PRECEDING AND SUCCEEDING YEARS FOR ANY ROW WHERE LIFE EXPECTANCY IS BLANK
SELECT 
	t1.Country, t1.Year, t1.`Life expectancy`, 
	t2.Country, t2.Year, t2.`Life expectancy`,
	t3.Country, t3.Year, t3.`Life expectancy`,
	ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country
		AND t1.Year = t2.Year - 1
	JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
		AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''    
;

-- USING THE LOGIC ABOVE
-- REPLACE THE BLANKS IN LIFE EXPECTANCY WITH THE AVERAGE LIFE EXPECTANCY FOR THE COUNTRY IN THE PRECEDING AND SUCCEEDING YEARS
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;