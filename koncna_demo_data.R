###### Loading packages #####
library(pacman)
p_load(lubridate, tidyverse, sparklyr, DBI)

# število subjektov v posamezni tabeli
nrow(skd_FURS)
nrow(ePRS)

# združvevanje tabel FURS in PRS
x <- inner_join(ePRS, skd_FURS, by = c("ma" = "maticna_stevilka"))
nrow(x)

##### Preverjanje podvojenih MA in DŠ #####
## podvojena matična številka
dupl_ma <- x[duplicated(x$ma), ]$ma
warning(paste("Število podvojenih matičnih številk:", length(dupl_ma)))


# podvojena matična v FURS-ovih datoteki 1.10.2018
# preverimo, kakšno je pravo ime subjekta - upoštevalo podatke ePRS - SILVO
skd_FURS[skd_FURS$maticna_stevilka == dupl_ma & !is.na(skd_FURS$maticna_stevilka), ]
ePRS[ePRS$ma == dupl_ma & !is.na(ePRS$ma), ]

# v našo končno bazo je bil kopirano pravo ime podvojene matične številke
x[duplicated(x$ma), ]


## podvojena davčna stevilka
dupl_ds <- x[duplicated(x$davcna_stevilka), ]$davcna_stevilka

# število podvojenih davčnih številk - gre za posameznike, ki imajo prijavljenih več dejavnosti? - ni težava ID bo MA
warning(paste("Število podvojenih davčnih številk:", length(dupl_ds)))

seznam_dupl_df <- skd_FURS[skd_FURS$davcna_stevilka %in% dupl_ds & !is.na(skd_FURS$davcna_stevilka), ]
write_delim(seznam_dupl_df,
            paste0("/Volumes/External/Magistrska/seznam_ds/duplicated_ds/duplicated_ds", format(Sys.Date(), format = "%Y_%m_%d"), ".csv"),
            delim = ";")

##### Preverjanje MISSING #####
warning(paste("Število subjektov, ki so vključeni v FURS podatke in ne v PRS:", nrow(y)))
y <- anti_join(skd_FURS, ePRS, by = c("maticna_stevilka" = "ma"))
nrow(y)


warning(paste("Število subjektov, ki so vključeni v PRS podatke in ne v FURS:", nrow(xx)))
xx <- anti_join(ePRS, skd_FURS, by = c("ma" = "maticna_stevilka"))
nrow(xx)

##### Urejanje tabele #####
x <- x %>% select(ma, davcna_stevilka, ime.x, oblika:do, financni_urad, tip, podrocje_kategorije:datum_prenehanja_DDV, -ime.y, -naslov) %>%
  rename(ime = ime.x)

##### Končna tabela #####
prs_furs <- x
head(prs_furs)

write_csv(prs_furs,
            paste0("/Volumes/External/Magistrska/PRS_FURS/PRS_FURS", format(Sys.Date(), format = "%Y_%m_%d"), ".csv"))


