###### Loading packages #####
library(pacman)
p_load(lubridate, data.table, tidyverse, XML)



##### Datum zadnje posodobitve seznama subjektov #####
# Seznam subjektov posodabljajo na vsake 3 mesece
last_refresh <- as.Date("2018-06-30", format = "%Y-%m-%d")
today <- as.Date(format(Sys.Date(), format = "%Y-%m-%d"))

diff_date <- diff.Date(c(last_refresh, today))


##### Download podatkov #####
url <- "https://www.ajpes.si/Doc/Registri/PRS/Ponovna_uporaba/Prs.zip"

# nalaganje XML direktno v R
# temp <- tempfile()
# download.file(url, temp)
# unzip(temp, exdir =  paste0("seznam_prs/prs_", format(Sys.Date(), format="%Y_%m_%d")))

if (diff_date > 92) { 
  # download in unzip XML v seznam_prs
  download.file(url, destfile = paste0("seznam_prs/prs_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"))
  unzip(paste0("seznam_prs/prs_", format(Sys.Date(), format="%Y_%m_%d"), ".zip"), exdir =  paste0("seznam_prs/prs_", format(Sys.Date(), format="%Y_%m_%d")))
  
  
  ##### Uvoz XML #####
  # pot do XML, zaradi sledlivosti je boljše, da DL + unzip, ker ohranimo tako datum
  path_xml <- paste0("seznam_prs/prs_", format(Sys.Date(), format="%Y_%m_%d"), "/Prs.xml")
  
  # uvoz podatkov v R
  xml <- xmlParse(file = path_xml)
  
  ##### Parse XML #####
  # število poslovnih subjektov zapisanih v poslovni register
  node_xml <- xmlRoot(xml)
  xmlSize(node_xml)
  
  # -1 ker je root zapis o obdelavi podatkov
  st_zapisov <- xmlSize(node_xml) - 1
  
  # parsing podatkov v vektorje
  ime <- xpathSApply(xml,"//PS/PopolnoIme",function(x) xmlSApply(x, xmlValue))
  oblika <- xpathSApply(xml,"//PS/Oblika",function(x) xmlSApply(x,xmlValue))
  organ <- xpathSApply(xml,"//PS/Organ",function(x) xmlSApply(x,xmlValue))
  naslov <- xpathSApply(xml,"//PS/N",function(x) xmlSApply(x,xmlValue))
  
  # število manjkajočih podatkov na 1. child ravni
  mis <- sum(st_zapisov - length(ime),
                st_zapisov - length(oblika),
                st_zapisov - length(organ),
                st_zapisov - length(naslov))
  
  ifelse(mis > 0, print(paste0("Na 1. child ravni je ", mis, " manjkajočih podatkov!")), "Ni manjkajočih podatkov na 1. child ravni!")
  
  ## Preverjanje manjkajočih podatkov na 1. ravni
  # preverjanje, če imamo manjkajoče podatke
  # XML ne moremo convertati v DT, če imamo manjkajoče enote
  if(st_zapisov == length(ime) & st_zapisov == length(oblika) & st_zapisov == length(organ) & st_zapisov == length(naslov)) {
    print("Ni manjkajočih podatkov!")
    } else {
      # pogledamo, kje imamo manjkajoče podatki na prvi child ravni
      c_attrs <- xpathSApply(xml,"//PS",function(x) xmlSApply(x, xmlName))
      
      # vsak vnos v ePR mora imeti 4 imena: PopolnoIme, Oblika, Organ, N
      attr_len <- sapply(c_attrs, length)
      
      # case-i z manjkajočimi podatki
      missing <- which(attr_len < 4, attr_len)
      warning(c("Manjkajoči podatki pri zapisih: ", paste(missing, collapse = ", ")))
      
      # pri katerih variablah so manjkajoče enote
      podatkovni_vec <- c()
      for (i in missing) {
        names <- names(c_attrs[[i]])
        all_names <- names(c_attrs[attr_len == 4][[1]])
        missing_names <- all_names[!all_names%in%names]
        podatkovni_vec <- c(podatkovni_vec, tolower(missing_names))
      }
  
      # vstavimo NA, kjer je manjkajoči podatek, da dobimo vektorje enake dolžine    
      for (i in 1:length(podatkovni_vec)) {
        j <- podatkovni_vec[i]
        k <- missing[i]
        assign(j, c(get(j)[seq(k-1)], NA, get(j)[seq(k, length(get(j)))]))
      }
    }
  
  # parsing podatkov na 2. child ravni v vektorje
  upravnaenota <- xpathSApply(xml,"//PS/N/UpravnaEnota",function(x) xmlSApply(x,xmlValue))
  regija <- xpathSApply(xml,"//PS/N/Regija",function(x) xmlSApply(x,xmlValue))
  obcina <- xpathSApply(xml,"//PS/N/Obcina",function(x) xmlSApply(x,xmlValue))
  posta <- xpathSApply(xml,"//PS/N/Posta",function(x) xmlSApply(x,xmlValue))
  naselje <- xpathSApply(xml,"//PS/N/Naselje",function(x) xmlSApply(x,xmlValue))
  ulica <- xpathSApply(xml,"//PS/N/Ulica",function(x) xmlSApply(x,xmlValue))
  
  # število manjkajočih podatkov na 2. child ravni
  cc_mis <- sum(st_zapisov - length(upravnaenota),
                st_zapisov - length(regija),
                st_zapisov - length(obcina),
                st_zapisov - length(posta),
                st_zapisov - length(naselje),
                st_zapisov - length(ulica))
  
  ifelse(cc_mis > 0, print(paste0("Na 2. child ravni je ", cc_mis, " manjkajočih podatkov!")), "Ni manjkajočih podatkov na 2. child ravni!")
  
  ## Preverjanje manjkajočih podatkov na 2. ravni
  # preverjanje, če imamo manjkajoče podatke
  # XML ne moremo convertati v DT, če imamo manjkajoče enote
  if(st_zapisov == length(upravnaenota) & st_zapisov == length(regija) & st_zapisov == length(obcina) & st_zapisov == length(posta) & st_zapisov == length(naselje) & st_zapisov == length(ulica)) {
    print("Ni manjkajočih podatkov!")
  } else {
     # pogledamo, kje imamo manjkajoče podatki na drugi child ravni (cc = child child)
    cc_attrs <- xpathSApply(xml,"//PS//N",function(x) xmlSApply(x, xmlName))
    
    # vsak vnos v ePR mora imeti 6 imen: UpravnaEnota, Regija, Občina, Pošta, Naselje in Ulica
    cc_attr_len <- sapply(cc_attrs, length)
    
    # case-i z manjkajočimi podatki
    cc_missing <- which(cc_attr_len < 6, cc_attr_len)
    warning(c("Manjkajoči podatki pri zapisih: ", paste(cc_missing, collapse = ", ")))
    
    # pri katerih variablah so manjkajoče enote
    cc_podatkovni_vec <- c()
    for (i in cc_missing) {
      names <- names(cc_attrs[[i]])
      all_names <- names(cc_attrs[cc_attr_len == 6][[1]])
      missing_names <- all_names[!all_names%in%names]
      cc_podatkovni_vec <- c(cc_podatkovni_vec, tolower(missing_names))
    }
    
    # vektor imen podatkov ni enake dolžine kot vektor s case-i, kje manjka podatek
    stopifnot(length(cc_podatkovni_vec) == length(cc_missing))
    
    # vstavimo NA, kjer je manjkajoči podatek, da dobimo vektorje enake dolžine    
    for (i in 1:length(cc_podatkovni_vec)) {
      j <- cc_podatkovni_vec[i]
      k <- cc_missing[i]
      assign(j, c(get(j)[seq(k-1)], NA, get(j)[seq(k, length(get(j)))]))
    }
  }
  
  # DT s podatki brez poštnih številk in hišnih številk
  data_raw <- data.table(ime, oblika, organ, upravnaenota, regija, obcina, posta, naselje, ulica)
  
  # attributi o poštni številki in hišni številki ter "do"
  att <- xpathSApply(xml,"//PS",function(x) xmlSApply(x, xmlAttrs))
  
  # preverimo, da imamo za vsak zapis vsaj 1 podatek
  stopifnot(length(att) == st_zapisov)
  
  # iz attributov potegnemo poštno številko, hišne številke in do
  po_hs_do <- sapply(att, function(x) {x$N})
  
  # počasen oneliner, kjer najprej transposamo, da dobimo matrike, te pretvorimo v DT, in rbindamo ter fillamo z NA
  data_att <- rbindlist(lapply(po_hs_do, function(v) {data.table(t(v))}), fill = TRUE)
  
  # dodamo matično številko
  ma <- xpathSApply(xml, "//PS" , xmlGetAttr, "ma")
  data_att <- bind_cols(data_att, ma = ma)
  
  # združimo podatke iz vseh child ravni
  ePRS <- bind_cols(data_raw, data_att)
  
  # preverimo, ali lahko matično številko res tretiramo kot ID (so vse enake?)
  if (sum(duplicated(ePRS[, "ma"], incomparables = FALSE)) != 0) {
    warning("Matične številko niso vse različne! Ne moreš jih uporabiti za ID!")
  }
  
  # dodami ID variable
  ePRS <- ePRS %>% 
            select(ma, ime, oblika, organ, upravnaenota, regija, obcina, po, posta, naselje, ulica, hs, do) %>% 
            rename(postna_stevilka = po, hisna_stevilka = hs) %>% 
            as_tibble()

  # ko naredimo refresh posodobimo datum zadnje posodobitve
  last_refresh <- today
}

# shranimo tabelo za future references
write.table(ePRS, 
            paste0("/Volumes/External/Magistrska/ePRS/merge_ePRS_", format(Sys.Date(), format="%Y_%m_%d"), ".csv"), 
            sep = ";", 
            col.names = TRUE,
            row.names = FALSE)



##### Končna tabela #####
head(ePRS)

























##### Dump #####
# for (j in podatkovni_vec) {
#   for (k in missing) {
#     assign(j, c(get(j)[seq(k-1)], NA, get(j)[seq(k, length(get(j)))]))
#   }
# }
# 
# 
# x <- 3
# vec <- c("a", "b", NA, "d", "e")
# vec1 <- c("a", "b", "c", "d", "e")
# vec2 <- c(vec1[seq(3)], NA, vec1[seq(3+1, length(vec1))])
# 
# 
# 
# i <- missing[1]
# names <- names(c_attrs[[i]])
# all_names <- names(c_attrs[attr_len == 4][[1]])
# missing_names <- all_names[!all_names%in%names]
# 
# 
# podatkovni_vec <- tolower(missing_names)
# organ_new <- organ
# podatkovni_vec <- "organ_new"
# 
# 
# for (i in podatkovni_vec) {
#   for (j in missing) {
#     assign(i, c(get(i)[seq(j)], NA, get(i)[seq(j + 1, length(get(i)))]))
#   }
# }
# 
# # naredimo ID variablo
# ID <- c(1:st_zapisov)
# 
# # 
# temp_data <- data.table(ID, ime, oblika, organ, naslov)
# node_xml[2]
# 
# 
# as_data_frame(naslov)
# t <- sapply(naslov, length)
# t[t < 6]
# 
# 
# i <- podatkovni_vec
# j <- missing[1]
# which(is.na(organ_new))
# 
# # XML ne moremo convertati v DT, če imamo manjkajoče enote
# c_attrs <- xpathSApply(xml,"//PS",function(x) xmlSApply(x, xmlName))
# 
# # vsak vnos v ePR mora imeti 4 
# attr_len <- sapply(c_attrs, length)
# which(attr_len < 4, attr_len)
# 
# 
# class(naslov)
# 
# ime[which(attr_len < 4, attr_len)]
# 
# 
# c_attrs[186614]
# xmlName(node_xml[186615])
# 
# 
# 
# 
# 
# 
# 
# x <- sapply(att, function(x) {x$N})
# max_len <- max(sapply(x, length))
# y <- lapply(x, function(x) {c(x, rep(NA, max_len - length(x)))})
# data.frame(y)
# 


