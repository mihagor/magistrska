###### Loading packages #####
library(pacman)
#devtools::install_github("dkahle/ggmap")
#devtools::install_github("gsk3/taRifx.geo")
p_load(sparklyr, tidyverse, purrr, sf, devtools, ggmap, googleway, taRifx.geo)




##### Spark connection #####
# path 
p <- "/Volumes/External/Magistrska/erar_csv/"
unzip_path <- paste0(p, "UNZIP/test/")

# spark konfiguracija
config <- spark_config()

# spark connection
sc <- spark_connect(master = "local")


trans_test <- spark_read_csv(path = unzip_path, 
                             name = "transakcije",
                             sc = sc,
                             delimiter = ";",
                             header = TRUE)


# spark_write_table(transakcije, "/Volumes/External/Magistrska/transakcije_rds/transakcije.rds")


# upload testnih podatkov
trans_test <- read_delim("/Volumes/External/Magistrska/erar_csv/UNZIP/test/trans_201807.csv", delim = ";")
prs_furs <- read_delim("/Volumes/External/Magistrska/PRS_FURS/PRS_FURS2018_10_01.csv", delim = ",")
# primer tabele: transakcije z vsemi podjetji, vsota transakcij v zadnjih 2 mesecih vsaj 1000 EUR
q1 <- trans_test %>% 
  group_by(maticna_stevilka) %>%
  summarise(stevilo_transakcij = n(), sum_transakcij = sum(znesek_transakcije, na.rm = TRUE)) %>%
  filter(sum_transakcij > 1000) %>%
  arrange(desc(sum_transakcij)) %>%
  collect()


xxx <- left_join(q1, prs_furs, by = c("maticna_stevilka" = "ma"))
sum(xxx$sum_transakcij) - xxx$sum_transakcij[1]

xxx <- 
  xxx %>%
    filter(!is.na(davcna_stevilka)) %>%
    unite("naslov", ulica, hisna_stevilka, naselje, sep = " ", remove = FALSE)

yyy <- xxx[1:2500, c("maticna_stevilka", "naslov")]
yyy <- paste0()

