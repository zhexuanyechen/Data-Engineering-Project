queries = {
    "update vaccination_by_municipality set CUMUL = 5 where cumul = '<10'",
    "update vaccination_by_municipality set NIS5 = 0 where nis5 is null",
    "alter table vaccination_by_municipality MODIFY COLUMN cumul int",
    "update population_info set population_info.TX_DESCR_NL = REGEXP_REPLACE(TX_DESCR_NL,'\\(.*\\)','')"
}