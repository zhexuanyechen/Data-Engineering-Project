

-- For the views I'm using the names with _

create or replace view vaccinationByMun as 
SELECT vac.nis5 as munCode, mun.munName, vac.YEAR_WEEK, vac.DOSE, SUM(vac.CUMUL) AS totalvaccinated
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT DISTINCT CD_REFNIS AS munCode, TX_DESCR_NL AS munName FROM population_info) AS mun
ON vac.nis5=mun.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1)
GROUP BY mun.munCode, vac.DOSE
ORDER BY mun.munCode;

create or replace view vaccinationByMunBC as 
SELECT vac.nis5 as munCode, mun.munName, vac.YEAR_WEEK, vac.DOSE, SUM(vac.CUMUL) AS totalvaccinated
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT DISTINCT CD_REFNIS AS munCode, TX_DESCR_NL AS munName FROM population_info) AS mun
ON vac.nis5=mun.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1) AND (DOSE="B" OR DOSE="C")
GROUP BY mun.munCode, vac.DOSE
ORDER BY mun.munCode;

create or replace view vaccinationByMunBCTotal as 
SELECT vac.nis5 as munCode, mun.munName, vac.YEAR_WEEK, SUM(vac.CUMUL) AS totalvaccinated
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT DISTINCT CD_REFNIS AS munCode, TX_DESCR_NL AS munName FROM population_info) AS mun
ON vac.nis5=mun.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1) AND (DOSE="B" OR DOSE="C")
GROUP BY mun.munCode
ORDER BY mun.munCode;

create or replace view vaccinationByMunPercentage as 
SELECT popDen.munCode, popDen.munName, vac.dose, SUM(vac.CUMUL) AS totalVaccinated, popDen.population, concat(round((SUM(vac.CUMUL)/popDen.population * 100), 2), '%') as percentage
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT nis5 AS munCode, municipalityNL AS munName, population as population FROM `population_density.xlsx-2020`) AS popDen
ON vac.nis5=popDen.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1)
GROUP BY vac.nis5, vac.DOSE
ORDER BY vac.nis5;

create or replace view vaccinationByMunBCTotalPercentage as 
SELECT popDen.munCode, popDen.munName, SUM(vac.CUMUL) AS totalFullyVaccinated, popDen.population, concat(round((SUM(vac.CUMUL)/popDen.population * 100), 2), '%') as percentage
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT nis5 AS munCode, municipalityNL AS munName, population as population FROM `population_density.xlsx-2020`) AS popDen
ON vac.nis5=popDen.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1) and (dose="B" or dose="C")
GROUP BY vac.nis5
ORDER BY vac.nis5;

create temporary table doseA as
select nis5, munName, YEAR_WEEK,  DOSE, CUMUL
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT DISTINCT CD_REFNIS AS munCode, TX_DESCR_NL AS munName FROM population_info) AS mun
ON vac.nis5=mun.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1) and DOSE = "A"
group by mun.munName
ORDER BY mun.munName;

create temporary table doseB as
select nis5, munName, YEAR_WEEK,  DOSE, CUMUL
FROM vaccination_by_municipality AS vac CROSS JOIN (SELECT DISTINCT CD_REFNIS AS munCode, TX_DESCR_NL AS munName FROM population_info) AS mun
ON vac.nis5=mun.muncode 
WHERE YEAR_WEEK = (SELECT YEAR_WEEK FROM vaccination_by_municipality
				ORDER BY YEAR_WEEK DESC LIMIT 1) and DOSE = "B"
group by mun.munName
ORDER BY mun.munName;

-- It's not possible to make a view of a temporary table, can change it if wanted
Select doseA.munName, doseA.cumul - doseB.cumul as nonFullyVac
from doseA, doseB
where doseA.nis5 = doseB.nis5
order by doseA.munName;

DROP TEMPORARY TABLE doseA;
DROP TEMPORARY TABLE doseB;

