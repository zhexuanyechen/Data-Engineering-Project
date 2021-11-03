queries = {
    "update vaccination_by_municipality set CUMUL = 5 where cumul = '<10'",
    "update vaccination_by_municipality set NIS5 = 0 where nis5 is null",
    "alter table vaccination_by_municipality MODIFY COLUMN cumul int",
    "update population_info set population_info.TX_DESCR_NL = REGEXP_REPLACE(TX_DESCR_NL,'\\(.*\\)','')",
    "ALTER TABLE DataEngineerDB.population_density.xlsx-2020 
    CHANGE COLUMN `index` `index` BIGINT(20) NULL ,
    CHANGE COLUMN `Population density by municipality 1st January 2020` `Nis5` INTEGER NULL ,
    CHANGE COLUMN `Unnamed: 1` `MunicipalityFR` TEXT NULL DEFAULT NULL ,
    CHANGE COLUMN `Unnamed: 2` `MunicipalityNL` TEXT NULL DEFAULT NULL ,
    CHANGE COLUMN `Unnamed: 3` `Population` BIGINT(20) NULL DEFAULT NULL ,
    CHANGE COLUMN `Unnamed: 4` `Size` DOUBLE(10,2) NULL DEFAULT NULL ,
    CHANGE COLUMN `Unnamed: 5` `Density` DOUBLE(10,2) NULL DEFAULT NULL ;"
}
