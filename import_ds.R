###### Loading packages #####
library(pacman)

p_load(lubridate, data.table, tidyverse, XML)



url_ds_po <- "http://datoteke.durs.gov.si/DURS_zavezanci_PO.zip"
url_ds_dej <- "http://datoteke.durs.gov.si/DURS_zavezanci_DEJ.zip"
url_ds_fo <- "http://datoteke.durs.gov.si/DURS_zavezanci_FO.zip"
url_ds_prek1 <- "http://datoteke.durs.gov.si/DURS_preklic_identifikacije%20DDV_NP.zip"
url_ds_prek2 <- "http://datoteke.durs.gov.si/DURS_preklic_identifikacije%20DDV_MT.zip"


po_dir <- paste0("/Volumes/External/Magistrska/seznam_ds/1_po/po_", format(Sys.Date(), format="%Y_%m_%d"))
dej_dir <- paste0("/Volumes/External/Magistrska/seznam_ds/2_dej/dej_", format(Sys.Date(), format="%Y_%m_%d"))
fo_dir <- paste0("/Volumes/External/Magistrska/seznam_ds/3_fo/fo_", format(Sys.Date(), format="%Y_%m_%d"))
prek1_dir <- paste0("/Volumes/External/Magistrska/seznam_ds/4_prek1/prek1_", format(Sys.Date(), format="%Y_%m_%d"))
prek2_dir <- paste0("/Volumes/External/Magistrska/seznam_ds/5_prek2/prek2_", format(Sys.Date(), format="%Y_%m_%d"))


##### Download podatkov #####
# download in unzip XML v seznam_ds
download.file(url_ds_po, destfile = paste0("/Volumes/External/Magistrska/seznam_ds/download/po/po_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"))
unzip(paste0("/Volumes/External/Magistrska/seznam_ds/download/po/po_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"), exdir =  po_dir)

download.file(url_ds_dej, destfile = paste0("/Volumes/External/Magistrska/seznam_ds/download/dej/dej_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"))
unzip(paste0("/Volumes/External/Magistrska/seznam_ds/download/dej/dej_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"), exdir =  dej_dir)

download.file(url_ds_fo, destfile = paste0("/Volumes/External/Magistrska/seznam_ds/download/fo/fo_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"))
unzip(paste0("/Volumes/External/Magistrska/seznam_ds/download/fo/fo_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"), exdir =  fo_dir)

download.file(url_ds_prek1, destfile = paste0("/Volumes/External/Magistrska/seznam_ds/download/prek1/prek1_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"))
unzip(paste0("/Volumes/External/Magistrska/seznam_ds/download/prek1/prek1_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"), exdir =  prek1_dir)

download.file(url_ds_prek2, destfile = paste0("/Volumes/External/Magistrska/seznam_ds/download/prek2/prek2_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"))
unzip(paste0("/Volumes/External/Magistrska/seznam_ds/download/prek2/prek2_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"), exdir =  prek2_dir)

##### Uvoz podatkov #####
## Pravne osebe
po <- suppressWarnings(read_fwf(paste0(po_dir, "/DURS_zavezanci_PO.txt"), 
               fwf_positions(c(1, 3, 5, 14, 25, 36, 43, 144, 258),
                             c(2, 4, 13, 24, 35, 42, 143, 257, 1000),
               col_names = c("placnik_DDV", "zavezanec_DDV", "davcna_stevilka", "maticna_stevilka", "datum_registracije", "skd", "ime", "naslov", "financni_urad")),
               col_types = "ccccccccc")
               )


po$tip <- "pravna oseba"




## Fizične osebe, ki opravljajo dejavnost (S.P.)
dej <- suppressWarnings(read_fwf(paste0(dej_dir, "/DURS_zavezanci_DEJ.txt"), 
                                 fwf_positions(c(1, 10, 21, 28, 129, 243),
                                               c(8, 19, 26, 128, 242, 1000),
                                               col_names = c("davcna_stevilka", "maticna_stevilka", "skd", "ime", "naslov", "financni_urad")),
                                 col_types = "cccccc")
                                 )


dej$tip <- "fizična oseba, ki opravlja dejavnost"





## Fizične osebe
# FO parsamo z read.fwf in ne read_fwf, saj zadnji nepravilno parsa zadnja 2 stolpca
fo <- read.fwf(paste0(fo_dir, "/DURS_zavezanci_FO.txt"),
               widths =  c(2, 9, 61, 112, 11, 2),
               col.names = c("placnik_DDV", "davcna_stevilka", "ime", "naslov", "datum_registracije", "financni_urad"),
               colClasses = c("character", "character", "character", "character", "character", "character"),
               strip.white = TRUE)  

# prazne stringe damo v NA in shranimo kot tibble, da se sklada z ostalimi
fo[fo == ""] <- NA
fo <- tbl_df(fo)

fo$tip <- "fizična oseba"





## Preklicana ID za DDV --> ne obstajajo več razlogi za identifikacijo za namene DDV (sam zaprl)
prek1 <- suppressWarnings(read_fwf(paste0(prek1_dir, "/DURS_preklic_identifikacije DDV_NP.txt"), 
                                 fwf_positions(c(1, 10, 21, 32, 132),
                                               c(8, 19, 30, 131, 1000),
                                               col_names = c("davcna_stevilka", "datum_pridobitve_DDV", "datum_prenehanja_DDV", "ime", "naslov")),
                                 col_types = "ccccc")
                                 )

prek1$tip <- "davčni zavezanec zaprl ID za DDV"



## Preklicana ID za DDV --> sum zlorabe identifikacije za namene DDV (FURS zaprl)
prek2 <- suppressWarnings(read_fwf(paste0(prek2_dir, "/DURS_preklic_identifikacije DDV_MT.txt"), 
                                   fwf_positions(c(1, 10, 21, 32, 132),
                                                 c(8, 19, 30, 131, 1000),
                                                 col_names = c("davcna_stevilka", "datum_pridobitve_DDV", "datum_prenehanja_DDV", "ime", "naslov")),
                                   col_types = "ccccc")
                                   )

prek2$tip <- "davčni organ zaprl ID za DDV"







##### Priprava podatkov za merge #####
# preverimo, ali je pravilno parsalo vse podatke
# !!posebno previden bodi, da je zadnji stolpec pravilno parsan!!
head(po, 10)
head(dej, 10)
head(fo, 10)
head(prek1, 10)
head(prek2, 10)





##### Združevanje vseh FURS-ovih podatkov #####
l <- list(po, dej, fo, prek1, prek2)
merge_FURS <- Reduce(function(...) merge(..., all = TRUE), l)

# transformiramo v tibble, uredimo vrstni red spremenljivk in binomiziramo psremenljivk zavezanec_DDV
merge_FURS <- 
  merge_FURS %>% 
    as.tibble() %>%
    select(davcna_stevilka, maticna_stevilka, tip, financni_urad, ime, naslov, skd, datum_registracije, placnik_DDV, zavezanec_DDV, datum_pridobitve_DDV, datum_prenehanja_DDV) %>%
    mutate(zavezanec_DDV = case_when(zavezanec_DDV == "*" ~ 1,
                                     is.na(zavezanec_DDV) ~ 0))
  
# uredimo še datume v pravilen format
merge_FURS <-
  merge_FURS %>%
    mutate(datum_registracije = as.Date(datum_registracije, format = c("%d.%m.%Y"))) %>%
    mutate(datum_pridobitve_DDV = as.Date(datum_pridobitve_DDV, format = c("%d.%m.%Y"))) %>%
    mutate(datum_prenehanja_DDV = as.Date(datum_prenehanja_DDV, format = c("%d.%m.%Y")))


# shranimo tabelo za future references
write_csv(merge_FURS, paste0("/Volumes/External/Magistrska/seznam_ds/merge_tabel/merge_FURS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"))


##### Končna tabela #####
head(merge_FURS)
























##### Dump #####
# string <- c("  * 10000658 6311881000 23.04.2013 68.310 RONI NEPREMIČNINE, POSREDOVANJE IN SVETOVANJE V PROMETU Z NEPREMIČNINAMI, D.O.O.                     HACQUETOVA ULICA 9, 1000 LJUBLJANA                                                                                08")
# split_string <- sapply(seq(from = 1, to = nchar(string), by = 1), function(x) {substr(string, x, x)})
# write.table(split_string, "string.csv", sep = ";")
# 
# 
# read_fwf(paste0(po_dir, "/DURS_zavezanci_PO.txt"), 
#          fwf_positions(c(1, 3, 5, 14, 25, 36, 43, 144, 258),
#                        c(2, 4, 13, 24, 35, 42, 143, 257, 1000)))
# 
# 
# dej_string <- c("10002561 6079601000 62.090 POSLOVNO SVETOVANJE, CVETKO KRIŽAN S.P.                                                              CESTA BRATSTVA 4 , 6000 KOPER - CAPODISTRIA                                                                       06")
# dej_split_string <- sapply(seq(from = 1, to = nchar(dej_string), by = 1), function(x) {substr(dej_string, x, x)})
# write.table(dej_split_string, "dej_string.csv", sep = ";")
# 
# 
# fo_string <- "P 10015337 GREGA BAŠIN                                                  PRESERJE 42 B, 1352 PRESERJE                                                                                    13.03.2013 08"
# fo_split_string <- sapply(seq(from = 1, to = nchar(fo_string), by = 1), function(x) {substr(fo_string, x, x)})
# write.table(fo_split_string, "fo_string.csv", sep = ";")
# 
# string <- "10001832 06.04.2007 31.12.2009 ALENKA KRAJNC                                                                                       ZADREČKA CESTA 2, 3331 NAZARJE"
# split_string <- sapply(seq(from = 1, to = nchar(string), by = 1), function(x) {substr(string, x, x)})
# write.table(split_string, "prek1.csv", sep = ";")
# 
