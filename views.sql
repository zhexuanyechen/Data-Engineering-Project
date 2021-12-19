

-- municipality_vaccination_income_total
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `municipality_vaccination_income_total` AS
    SELECT 
        `popden`.`munCode` AS `munCode`,
        `popinfo`.`munName` AS `Municipality`,
        SUM(`vac`.`cumul`) AS `Total fully vaccinated`,
        `popden`.`population` AS `population`,
        ROUND(((SUM(`vac`.`cumul`) / `popden`.`population`) * 100),
                2) AS `Percentage vaccinated`,
        `income`.`Average income/year` AS `Average income/year`,
        `income`.`Average income/month` AS `Average income/month`,
        `popden`.`density` AS `density`
    FROM
        (((`vaccination_by_municipality` `vac`
        LEFT JOIN (SELECT 
            `mp_population_density`.`Refnis` AS `munCode`,
                `mp_population_density`.`Municipality NL` AS `munName`,
                `mp_population_density`.`Population` AS `population`,
                `mp_population_density`.Population / kmÂ² AS density
        FROM
            mp_population_density) popden ON ((vac.NIS5 = popden.munCode)))
        LEFT JOIN (SELECT DISTINCT
            population_info.CD_REFNIS AS muncode,
                population_info.TX_DESCR_NL AS munName
        FROM
            population_info) popinfo ON ((vac.NIS5 = popinfo.muncode)))
        LEFT JOIN (SELECT 
            mp_income_statistics.CD_MUNTY_REFNIS AS Refnis,
                ROUND((mp_income_statistics.MS_TOT_NET_INC / mp_income_statistics.MS_TOT_RESIDENTS), 2) AS Average income/year,
                ROUND(((mp_income_statistics.MS_TOT_NET_INC / mp_income_statistics.MS_TOT_RESIDENTS) / 12), 2) AS Average income/month
        FROM
            mp_income_statistics
        WHERE
            (mp_income_statistics.CD_YEAR = 2019)) income ON ((vac.NIS5 = income.Refnis)))
    WHERE
        ((vac.YEAR_WEEK = (SELECT 
                vaccination_by_municipality.YEAR_WEEK
            FROM
                vaccination_by_municipality
            ORDER BY vaccination_by_municipality.YEAR_WEEK DESC
            LIMIT 1))
            AND ((vac.DOSE = 'B') OR (vac.DOSE = 'C')))
    GROUP BY vac.NIS5
    ORDER BY vac.NIS5


-- municiaplity_vaccination_native
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `municiaplity_vaccination_native` AS
    SELECT 
        `popden`.`munCode` AS `munCode`,
        `popinfo`.`munName` AS `munName`,
        SUM(`vac`.`cumul`) AS `Total fully vaccinated`,
        `popden`.`population` AS `population`,
        ROUND(((SUM(`vac`.`cumul`) / `popden`.`population`) * 100),
                2) AS `Vaccinated (%)`,
        `origin`.`Born in Belgium (%)` AS `Born in Belgium (%)`,
        `income`.`Average income/year` AS `Average income/year`,
        `income`.`Average income/motnh` AS `Average income/motnh`
    FROM
        ((((`vaccination_by_municipality` `vac`
        LEFT JOIN (SELECT 
            `mp_population_density`.`Refnis` AS `munCode`,
                `mp_population_density`.`Municipality NL` AS `munName`,
                `mp_population_density`.`Population` AS `population`
        FROM
            `mp_population_density`) `popden` ON ((`vac`.`NIS5` = `popden`.`munCode`)))
        LEFT JOIN (SELECT DISTINCT
            `population_info`.`CD_REFNIS` AS `muncode`,
                `population_info`.`TX_DESCR_NL` AS `munName`
        FROM
            `population_info`) `popinfo` ON ((`vac`.`NIS5` = `popinfo`.`muncode`)))
        LEFT JOIN (SELECT 
            `mp_income_statistics`.`CD_MUNTY_REFNIS` AS `Refnis`,
                ROUND((`mp_income_statistics`.`MS_TOT_NET_INC` / `mp_income_statistics`.`MS_TOT_RESIDENTS`), 2) AS `Average income/year`,
                ROUND(((`mp_income_statistics`.`MS_TOT_NET_INC` / `mp_income_statistics`.`MS_TOT_RESIDENTS`) / 12), 2) AS `Average income/motnh`
        FROM
            `mp_income_statistics`
        WHERE
            (`mp_income_statistics`.`CD_YEAR` = 2019)) `income` ON ((`vac`.`NIS5` = `income`.`Refnis`)))
        LEFT JOIN (SELECT 
            `mp_herkomst_municipality2021`.`NIS code` AS `NIS code`,
                `mp_herkomst_municipality2021`.`Woonplaats` AS `Woonplaats`,
                ROUND(((`mp_herkomst_municipality2021`.Geboren in BelgiÃ« / mp_herkomst_municipality2021.Totaal) * 100), 2) AS Born in Belgium (%)
        FROM
            mp_herkomst_municipality2021) origin ON ((vac.NIS5 = origin.NIS code)))
    WHERE
        ((vac.YEAR_WEEK = (SELECT 
                vaccination_by_municipality.YEAR_WEEK
            FROM
                vaccination_by_municipality
            ORDER BY vaccination_by_municipality.YEAR_WEEK DESC
            LIMIT 1))
            AND ((vac.DOSE = 'B') OR (vac.DOSE = 'C'))
            AND (popden.munCode IS NOT NULL))
    GROUP BY vac.NIS5
    ORDER BY vac.NIS5

-- province_cases_pollution
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `province_cases_pollution` AS
    SELECT 
        `mun`.`provinceCode` AS `Provice Code`,
        `mun`.`provinceName` AS `provinceName`,
        `vac`.`YEAR_WEEK` AS `YEAR_WEEK`,
        `cases`.`Total Cases` AS `Total Cases`,
        `pollution`.`pollutant` AS `pollutant`,
        `pollution`.`Pollutant Value` AS `Pollutant Value`
    FROM
        (((`vaccination_by_municipality` `vac`
        JOIN (SELECT DISTINCT
            `population_info`.`CD_PROV_REFNIS` AS `provinceCode`,
                `population_info`.`CD_REFNIS` AS `muncode`,
                `population_info`.`TX_PROV_DESCR_NL` AS `provinceName`
        FROM
            `population_info`) `mun` ON ((`vac`.`NIS5` = `mun`.`muncode`)))
        LEFT JOIN (SELECT 
            SUM(`cases_municipality`.`CASES`) AS `Total Cases`,
                `cases_municipality`.`PROVINCE` AS `province`,
                `cases_municipality`.`NIS5` AS `NIS5`
        FROM
            `cases_municipality`
        GROUP BY `cases_municipality`.`PROVINCE`) `cases` ON ((`vac`.`NIS5` = `cases`.`NIS5`)))
        LEFT JOIN (SELECT 
            `mp_province_pollution`.`City` AS `city`,
                `mp_province_pollution`.`Pollutant` AS `pollutant`,
                `mp_province_pollution`.`Unit` AS `unit`,
                `mp_province_pollution`.`NIS5` AS `nis5`,
                SUM(`mp_province_pollution`.`Value`) AS `Pollutant Value`
        FROM
            `mp_province_pollution`
        GROUP BY `mp_province_pollution`.`City` , `mp_province_pollution`.`Pollutant`) `pollution` ON ((`mun`.`provinceCode` = `pollution`.`nis5`)))
    WHERE
        ((`vac`.`YEAR_WEEK` = (SELECT 
                `vaccination_by_municipality`.`YEAR_WEEK`
            FROM
                `vaccination_by_municipality`
            ORDER BY `vaccination_by_municipality`.`YEAR_WEEK` DESC
            LIMIT 1))
            AND (`mun`.`provinceCode` IS NOT NULL)
            AND (NOT ((`mun`.`provinceCode` LIKE 400))))
    GROUP BY `mun`.`provinceCode` , `pollution`.`pollutant`
    ORDER BY `mun`.`provinceCode`

-- region_vaccination
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `region_vaccination` AS
    SELECT 
        `mun`.`regionCode` AS `Region Code`,
        `mun`.`regionName` AS `regionName`,
        `vac`.`YEAR_WEEK` AS `YEAR_WEEK`,
        `vac`.`DOSE` AS `DOSE`,
        SUM(`vac`.`cumul`) AS `totalFullyVaccinated`,
        `popden`.`population` AS `population`,
        CONCAT(ROUND(((SUM(`vac`.`cumul`) / `popden`.`population`) * 100),
                        2),
                '%') AS `percentage`
    FROM
        ((`vaccination_by_municipality` `vac`
        JOIN (SELECT DISTINCT
            `population_info`.`CD_RGN_REFNIS` AS `regionCode`,
                `population_info`.`CD_REFNIS` AS `muncode`,
                `population_info`.`TX_RGN_DESCR_NL` AS `regionName`
        FROM
            `population_info`) `mun` ON ((`vac`.`NIS5` = `mun`.`muncode`)))
        LEFT JOIN (SELECT 
            `mp_population_density`.`Refnis` AS `munCode`,
                `mp_population_density`.`Municipality NL` AS `munName`,
                `mp_population_density`.`Population` AS `population`
        FROM
            `mp_population_density`) `popden` ON ((`mun`.`regionCode` = `popden`.`munCode`)))
    WHERE
        ((`vac`.`YEAR_WEEK` = (SELECT 
                `vaccination_by_municipality`.`YEAR_WEEK`
            FROM
                `vaccination_by_municipality`
            ORDER BY `vaccination_by_municipality`.`YEAR_WEEK` DESC
            LIMIT 1))
            AND ((`vac`.`DOSE` = 'B')
            OR (`vac`.`DOSE` = 'C')))
    GROUP BY `mun`.`regionCode`
    ORDER BY `mun`.`regionCode`

-- vaccination_by_province_total
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vaccination_by_province_total` AS
    SELECT 
        `mun`.`provinceCode` AS `Provice Code`,
        `mun`.`provinceName` AS `provinceName`,
        `vac`.`YEAR_WEEK` AS `YEAR_WEEK`,
        `vac`.`DOSE` AS `DOSE`,
        SUM(`vac`.`cumul`) AS `totalFullyVaccinated`,
        `popden`.`population` AS `population`,
        CONCAT(ROUND(((SUM(`vac`.`cumul`) / `popden`.`population`) * 100),
                        2),
                '%') AS `percentage`
    FROM
        ((`vaccination_by_municipality` `vac`
        JOIN (SELECT DISTINCT
            `population_info`.`CD_PROV_REFNIS` AS `provinceCode`,
                `population_info`.`CD_REFNIS` AS `muncode`,
                `population_info`.`TX_PROV_DESCR_NL` AS `provinceName`
        FROM
            `population_info`) `mun` ON ((`vac`.`NIS5` = `mun`.`muncode`)))
        LEFT JOIN (SELECT 
            `mp_population_density`.`Refnis` AS `munCode`,
                'Municipality NL' AS `munName`,
                `mp_population_density`.`Population` AS `population`
        FROM
            `mp_population_density`) `popden` ON ((`mun`.`provinceCode` = `popden`.`munCode`)))
    WHERE
        ((`vac`.`YEAR_WEEK` = (SELECT 
                `vaccination_by_municipality`.`YEAR_WEEK`
            FROM
                `vaccination_by_municipality`
            ORDER BY `vaccination_by_municipality`.`YEAR_WEEK` DESC
            LIMIT 1))
            AND ((`vac`.`DOSE` = 'B')
            OR (`vac`.`DOSE` = 'C'))
            AND (NOT ((`mun`.`provinceCode` LIKE 400))))
    GROUP BY `mun`.`provinceCode` , `vac`.`DOSE`
    ORDER BY `mun`.`provinceCode`