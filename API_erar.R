###### Loading packages #####
library(pacman)

p_load(httr, jsonlite, lubridate, data.table, tidyverse)
options(stringsAsFactors = FALSE)

##### Uvoz csv julij #####
julij <- read.csv2("trans201806.csv")
setDT(julij)

# imena spremenljivk
names(julij)

# toliko imamo različnih davčnih številk
length(unique(julij[["davcna_stevilka"]]))

julij[["davcna_stevilka"]][10] 
#####

##### API #####
url <- "https://erar.si"
path <- "/api/eracuni/?prejemnik=21881677"

raw_result <- GET(url = url, path = path)
str(raw.result)

# če je status_code == 200 potem je vse ok
raw_result$status_code


raw_result_char <- rawToChar(raw_result$content)
nchar(raw_result_char)

raw_results_list <- fromJSON(raw_result_char)
class(raw_results_list)
length(raw_results_list)

# vseh zajetih transakcij
raw_results_list[1]

# vseh dobljenih transakcij (filtered?)
raw_results_list[2]

# kaj pomeni draw?
raw_results_list[3]

# status ...
raw_results_list[4]

# error-ji
raw_results_list[5]

# TRUE kadar ni errorjev!
length(raw_results_list[[5]]) == 0

# podatki
raw_results_list[6]

podatki <- as.data.table(raw_results_list[6])

glimpse(podatki)
