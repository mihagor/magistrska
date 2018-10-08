##### Dodajanje deskriptorjev kodam SKD #####
##### Uvod podatkov #####

skd_FURS <- read_csv(file = paste0("/Volumes/External/Magistrska/seznam_ds/merge_tabel/merge_FURS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"),
                     col_types = cols(maticna_stevilka = col_character()))

skd <- read_delim("/Users/mihagornik/Google Drive/Faks/2. stopnja/Magistrska naloga/SKD.csv", delim = ";")


# FURS-ovim podatkom dodamo še podateke, ki jih dobimo iz skd, oddelek, skupina in razred
skd_FURS <- 
  skd_FURS %>% 
  separate(col = "skd", into = c("oddelek", "tmp0"), sep = "\\.", remove = FALSE) %>%
  separate(col = "tmp0", into = c("tmp1", "tmp2", "tmp3"), sep = c(1, 2), remove = FALSE) %>%
  unite(col = "skupina", oddelek, tmp1, sep = ".", remove = FALSE) %>%
  unite(col = "tmp4", tmp1, tmp2, sep = "", remove = FALSE) %>%
  unite(col = "razred", oddelek, tmp4, sep = ".", remove = FALSE) %>%
  select(davcna_stevilka, 
         maticna_stevilka, 
         tip, 
         financni_urad, 
         ime, 
         naslov, 
         oddelek, 
         skupina, 
         razred, 
         podrocje = skd, 
         datum_registracije, 
         placnik_DDV, 
         zavezanec_DDV, 
         datum_pridobitve_DDV, 
         datum_prenehanja_DDV)


# prilagodimo imena stolpcev, da ne bo problemov pri nadaljnih obdelavah
colnames(skd) <- colnames(skd) %>% 
                    tolower() %>%
                    str_replace(" ", "\\_") %>% 
                    str_replace_all("š", "s")

# parsamo podatke, da ustrezajo našim zahtevam, razdružimo 1 črko, ki predstavlja področje v svoj stolpec
skd <-  
  skd %>%
  as_tibble() %>% 
  separate(sifra_kategorije, into = c("podrocje_kategorije", "sifra_kategorije"), sep = 1) %>%
  select(podrocje_kategorije, sifra_kategorije, desktriptor)


# matchamo skd sifre z deskriptorji
oddelek <- left_join(skd_FURS, skd, by = c("oddelek" = "sifra_kategorije")) %>% select(podrocje_kategorije, desktriptor)
skupina <- left_join(skd_FURS, skd, by = c("skupina" = "sifra_kategorije")) %>% select(desktriptor)
razred <- left_join(skd_FURS, skd, by = c("razred" = "sifra_kategorije")) %>% select(desktriptor)
podrocje <- left_join(skd_FURS, skd, by = c("podrocje" = "sifra_kategorije")) %>% select(desktriptor)

# df z vsemi deskriptorji in področju kategorije
skd_long <- bind_cols(oddelek, skupina, razred, podrocje)
colnames(skd_long) <- c("podrocje_kategorije", "oddelek_long", "skupina_long", "razred_long", "podrocje_long")

# dodamo deskriptorje FURS-ovim podatkom
skd_FURS <- bind_cols(skd_FURS, skd_long)


# zaradi parsanja na seperate dobimo stringe "NA.NA" in "NA.NANA" -> to spremenimo v NA
skd_FURS$skupina[grepl("^NA", skd_FURS$skupina)] <- NA
skd_FURS$razred[grepl("^NA", skd_FURS$razred)] <- NA


# filtriramo, da dobimo samo deskriptorje področij katerogij na 1. ravni
podrocje_kategorije_long <- skd %>% filter(sifra_kategorije == "") %>% select(-2)

# dodamo podatke še o področju kategorije (kaj pomeni A, B, ...) -> 1. raven
skd_FURS <- left_join(skd_FURS, podrocje_kategorije_long, by = "podrocje_kategorije")
colnames(skd_FURS)[ncol(skd_FURS)] <- "podrocje_kategorije_long"

# uredimo vrstni red spremenljivk
skd_FURS <-
  skd_FURS %>%
    select(davcna_stevilka:naslov, 
           podrocje_kategorije, podrocje_kategorije_long,
           oddelek, oddelek_long, 
           skupina, skupina_long, 
           razred, razred_long, 
           podrocje, podrocje_long, 
           datum_registracije, 
           placnik_DDV, zavezanec_DDV,
           datum_pridobitve_DDV, datum_prenehanja_DDV)


# shranimo tabelo za future references
write_csv(skd_FURS, paste0("/Volumes/External/Magistrska/skd_FURS/skd_FURS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"))



##### Končna tabela #####
head(skd_FURS)

