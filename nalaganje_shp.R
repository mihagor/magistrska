###### Loading packages #####
library("pacman")

p_load(rgdal, rgeos, ggmap, maptools, sp, leaflet)

#slo_mat <- readOGR("/Volumes/External/Magistrska/shapes/DTM_BU", "BU_STAVBE_P")
#plot(slo_mat)

##### Leaflet #####

dark_template <- "https://api.mapbox.com/styles/v1/mihag/cjmqcy3ao73g12rpcewrp43rl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWloYWciLCJhIjoiY2ptcTl1cXhnMDB0NjNwa2gwNDQ3NzF0eCJ9.EtLPziDHukpLrHL0cPXXYw"

leaflet(data = cc) %>% 
  addTiles(urlTemplate = dark_template) %>%
  addMarkers(~lon, 
             ~lat, 
             label = ~as.character(ime),
             popup = ~as.character(sum_transakcij))

##### Geocoding #####











