###### Loading packages #####
library(pacman)
p_load(lubridate, tidyverse, sparklyr, DBI)

# spark connection
sc <- spark_connect(master = "local")

## najprej naredimo upload VSEH podatkov (če so kje manjkajoči, da lahko iščemo informacije za nazaj)
# uvoz FURS podatkov v Spark 
FURS <- spark_read_csv(path = paste0("/Volumes/External/Magistrska/seznam_ds/merge_tabel/merge_FURS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"), 
                          name = "FURS",
                          sc = sc,
                          delimiter = ",",
                          header = TRUE)

# uvoz podatkov o SKD podatkov v Spark 
SKD <- spark_read_csv(path = paste0("/Volumes/External/Magistrska/skd_FURS/skd_FURS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"), 
                               name = "SKD",
                               sc = sc,
                               delimiter = ",",
                               header = TRUE)

# uvoz podatkov o ePRS podatkov v Spark 
PRS <- spark_read_csv(path = paste0("/Volumes/External/Magistrska/ePRS/merge_ePRS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"), 
                              name = "ePRS",
                              sc = sc,
                              delimiter = ",",
                              header = TRUE)


FURS_PRS <- spark_read_csv(path = paste0("/Volumes/External/Magistrska/PRS_FURS/PRS_FURS", format(Sys.Date(), format="%Y_%m_%d"), ".csv"), 
                           name = "prs_furs",
                           sc = sc,
                           delimiter = ",",
                           header = TRUE)

# seznam tabel v Sparku
src_tbls(sc)



##### Disconnect od Sparka #####
spark_disconnect(sc)







