-- WORLD LIFE EXPECTANCY PROJECT (EXPORATORY DATA ANALYSIS)

SELECT * 
FROM world_life_expectancy
;

-- IDENTIFYING THE COUNTRIES WITH THE LARGEST DIFFERENCE IN LIFE EXPECTANCY
SELECT Country, 
MIN(`Life expectancy`) as min,
MAX(`Life expectancy`) as max,
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) as difference
FROM world_life_expectancy
GROUP BY Country
HAVING min <> 0
AND max <> 0
ORDER BY difference desc
;

-- IDENTIFYING THE AVERAGE LIFE EXPECTANCY (ALL COUNTRIES WHICH LE <> 0) BY YEAR
SELECT Year, ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year desc
;

-- COMPARING LIFE EXPECTANCY TO GDP FOR EACH COUNTRY
SELECT Country, ROUND(AVG(`Life expectancy`),0) as Life_Exp, ROUND(AVG(GDP),0) as GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP ASC
;


-- IDENTIFYING COUNTRIES WHOSE AVERAGE GDP IS ABOVE OR BELOW THE AVERAGE WORLD GDP 
SELECT Country, AVG(GDP), 
    CASE WHEN AVG(GDP) > (SELECT AVG(GDP) FROM world_life_Expectancy) 
    THEN 'Above Average' 
    ELSE 'Below Average'
    END as Average_GDP
FROM world_life_expectancy
GROUP BY Country
;

-- AVERAGE GDP = 7483
SELECT ROUND(AVG(GDP),0)
FROM world_life_expectancy
WHERE GDP <> 0
;

-- COMPARING LIFE EXPECTANCY BETWEEN ABOVE AND BELOW AVERAGE GDP
SELECT
SUM(CASE WHEN GDP >= 7483 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 7483 THEN `Life expectancy` ELSE NULL END) High_GDP_LE,
SUM(CASE WHEN GDP < 7483 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP < 7483 THEN `Life expectancy` ELSE NULL END) Low_GDP_LE
FROM world_life_expectancy
;

-- COMPARING COUNT AND AVERAGE LIFE EXPECTANCY BETWEEN DEVELOPING AND DEVELOPED COUNTRIES
SELECT Status, COUNT(DISTINCT Country) Countries, ROUND(AVG(`Life expectancy`),0) LE
FROM world_life_expectancy
GROUP BY Status
;


-- ROLLING TOTAL OF ADULT MORTALITY
SELECT Country, Year, `Life expectancy`, `Adult Mortality`, 
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) as Rolling_total
FROM world_life_expectancy
;
