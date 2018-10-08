###### Loading packages #####
library(pacman)
p_load(sparklyr, tidyverse, purrr)

#spark_install(version = "2.3.1")
#devtools::install_github("rstudio/sparklyr")

##### Data for Download #####

# url za download podatkov
url_erar <- "https://erar.si/cdn/podatki/trans"



# tekoče leto in tekoči mesec
this_year <- format(Sys.Date(), format="%Y")
month <- format(Sys.Date(), format="%m")

# leta za katera želimo podatke
years <- c(2003:this_year)

# meseci v tekočem letu za katere želimo podatke
months <- c()
for (i in c(1:month)) {
  if (nchar(i) < 2) {
    i <- paste0("0", i) 
  }
  months <- c(months, i)  
}

##### Download & Unzip #####
# zunanji path
p <- "/Volumes/External/Magistrska/erar_csv/"

# podatki, ki so že DL
file_str <- str_split(dir(p), "\\_|\\.")
file_str <- sapply(file_str, function(x) {x[2]})

# podatki, katere bi želeli imeti DL
datumi_do_sedaj <- c(years[-length(years)], paste0(years[length(years)], months))

# podatke za katere mesece ali leta je potrebno še downloadati
potrebno_DL <- datumi_do_sedaj[!(datumi_do_sedaj %in% file_str)]

for (i in potrebno_DL) {
  koncnica <- ".csv.gz"
  if (nchar(i) == 4) {
    
    leto <- i 
    # ime csv datoteke, katero želimo downloadati
    ime_file <- paste0(url_erar, leto, koncnica)
    
    if(i != this_year) { 
      # download podatkov
      dl_path <- paste0(p, "trans_", leto, koncnica)
      download.file(ime_file,  destfile = dl_path) 
      
      # unzip podatkov
      unzip_path <- paste0(p, "UNZIP/")
      ime_unzip <- paste0("trans_", leto)
      R.utils::gunzip(dl_path, destname =  paste0(unzip_path, ime_unzip, ".csv"), remove = FALSE)
    }
      
  } else if (nchar(i) == 6) {
    
    leto <- i
    ime_file <- paste0(url_erar, leto, koncnica)
    
    # download podatkov
    dl_path <- paste0(p, "trans_", leto, koncnica)
    download.file(ime_file,  destfile = dl_path)
    
    # unzip podatkov
    unzip_path <- paste0(p, "UNZIP/")
    ime_unzip <- paste0("trans_", leto)
    R.utils::gunzip(dl_path, destname =  paste0(unzip_path, ime_unzip, ".csv"), remove = FALSE)
    
  }
}







