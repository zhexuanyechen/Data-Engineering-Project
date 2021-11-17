queries = {
    "update vaccination_by_municipality set CUMUL = '5' where cumul = '<10'",
    "update vaccination_by_municipality set NIS5 = 0 where nis5 is null",
    "alter table vaccination_by_municipality MODIFY COLUMN cumul int",
    "update population_info set CD_PROV_REFNIS = 400 where CD_Dstr_refnis = 21000 ;",
    "update population_info set TX_PROV_DESCR_NL = 'Brussel' where cd_prov_refnis = 400",
    "update population_info set TX_PROV_DESCR_NL = 'other' where TX_PROV_DESCR_NL is null",
    "update population_info set CD_PROV_REFNIS = 0 where CD_PROV_REFNIS is null"
}