/*
Building a dashboard that
- shows percentage of flu vaccination of patients over time (01.01.2010–31.12.2010)
-         "               "             "        by age, ethnicity, county

The patient must be active. A patient is considered active when he or she
- had an encounter in the last few years
- is still alive
- is older than six months


Data source: https://synthetichealth.github.io/synthea/
*/




-- Get the Ids of active patients
WITH active_patients AS
(
SELECT p.Id FROM patients AS p
JOIN encounters AS e
ON p.Id = e.PATIENT
WHERE STOP BETWEEN '2008-01-01 00:00' AND '2010-12-31 23:59'
AND DEATHDATE IS NULL
AND DATEDIFF(MONTH, BIRTHDATE, '2010-12-31') >= 6
),




-- Get the Date of vaccination
flu_shot_2010 AS
(
SELECT PATIENT, min(DATE) as flu_shot_date FROM immunizations
WHERE CODE = '140'
AND DATE BETWEEN '2010-01-01 00:00' AND '2010-12-31 23:59'
GROUP BY PATIENT
)




SELECT 
	DATEDIFF(YEAR, BIRTHDATE, '2010-12-31') AS age,
	RACE AS ethnicity,
	COUNTY AS county,
	f.flu_shot_date AS first_flu_shot,
	CASE WHEN f.flu_shot_date IS NOT NULL THEN 1 ELSE 0 END AS flu_shot
FROM patients AS p
LEFT JOIN flu_shot_2010 AS f
ON p.Id = f.patient
WHERE p.ID IN (SELECT Id FROM active_patients)

