

p_load(sparklyr, tidyverse, purrr, sf, devtools, ggmap, googleway, taRifx.geo)


##### Geocoding with google #####
# To dela, ampak je plačlivo - uporabi raje Bing
register_google(key = "AIzaSyANkCFoDkh6UOimW4lA6Bf6PQX2IFDObhk",
                account_type = "standard",
                day_limit = 2500)
ggmap_credentials()
geocodeQueryCheck()

c <- geocode(as.character(yyy[2, 2]), output = "all", source = "google", inject = "region=si", messaging = TRUE, override_limit = TRUE)
#####


##### Geocoding with Bing #####
# daily limit je 25k
# bing api key
options(BingMapsKey='Agc3lFsAn0w_pdlim6B2k4LK3MtG_JA9Hd-W1P2sTBeiKF6twda0_5OUlQFukV69')
z <- taRifx.geo::geocode(yyy[1:10,], addresscol = "naslov", verbose = TRUE, service = "bing")

