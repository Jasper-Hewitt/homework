install.packages("ggspatial")
install.packages("stringr")
install.packages("spdep")
install.packages("rgdal")
#install.packages("GISTools")
install.packages("raster")
install.packages("maptools")
install.packages("leaflet")
install.packages("htmlwidgets")
install.packages("RDM")

https://raw.githubusercontent.com/Jasper-Hewitt/elec_fertility/main/data/newtaipei_hou.csv
library(readr)



remotes::install_github("cran/GISTools")

library(RDM)
library(plyr)
library(readr)
library(stringr)
library(ggspatial)
library(ggplot2)
library(dplyr)
library(tidyr)
library(spdep)
library(rgdal)
library(GISTools)
library(raster)
library(maptools)
library(leaflet)
library(htmlwidgets)

install.packages('ggspatial')

options(warn = -1)

setwd("/Users/jasperhewitt/Desktop/big data & social analysis/code/datasets")

#GIS

map <- shapefile("cb_2017_us_county_500k/cb_2017_us_county_500k.shp")

map_1 <- readOGR("cb_2017_us_county_500k/cb_2017_us_county_500k.shp")

#You can use plot() to see the shapefile plot.
plot(map)

us_data <- map@data

#We can merge our data into map's data. Data about soy beans
soybean <- read.csv('soybean.csv')

soybean$Value <- parse_number(soybean$Value)

#why not soybean$Value <- as.numeric(soybean$Value)?

soybean <- dplyr::rename(soybean, value = Value)

#change the state ids so thatthey match. in one of the codes it is 1 and in the other it's 01
soybean$State.ANSI <- as.character(soybean$State.ANSI)
soybean$County.ANSI <- as.character(soybean$County.ANSI)

#Add zero before the state and county codes
soybean$GEOID <- paste0(str_pad(soybean$State.ANSI, 2, pad = "0"), str_pad(soybean$County.ANSI, 3, pad = "0"))

#so now we can finally merge it
#We can't use dplyr's left_join in shapefile
map <- merge(map, soybean[, c(6, 10, 20, 22)], by = c("GEOID"))

us_data <- map@data

#Use ggplot to plot
#Here is the basic codes

ggplot(map, aes(x = long, y = lat, group = group)) +
  geom_polygon()


#Cut Kentucky's shapefile

map <- map[map$STATEFP == '20',]

#plotting this takes ages. and doesn't show much lol. 
ggplot(map, aes(x = long, y = lat, group = group)) +
  geom_polygon(color = "black", size = 0.1)

View(map@data)

map$value

map$value[is.na(map$value) == TRUE] <- 0

map$value

ggplot(map, aes(x = long, y = lat, group = group, fill = value)) +
  geom_polygon()


ggplot() +
  annotation_spatial(map) +
  layer_spatial(map, aes(fill = value))

ggplot() +
  annotation_spatial(map) +
  layer_spatial(map, aes(fill = value)) +
  scale_fill_gradient(low = "#ffffcc", high = "#ff4444", 
                      space = "Lab", na.value = "grey50",
                      guide = "colourbar")



#practice____________________________________________________________________________

#we know do the same for Illionois


map <- shapefile("cb_2017_us_county_500k/cb_2017_us_county_500k.shp")


wheat <- read.csv("wheat winter.csv")

wheat$Value <- parse_number(wheat$Value)

wheat <- rename(wheat, value = Value)

wheat$State.ANSI <- as.character(wheat$State.ANSI)
wheat$County.ANSI <- as.character(wheat$County.ANSI)

#make state ids the same
wheat$GEOID <- paste0(str_pad(wheat$State.ANSI, 2, pad = "0"), str_pad(wheat$County.ANSI, 3, pad = "0"))



map <- merge(map, wheat[, c(6, 10, 20, 22)], by = c("GEOID"))

#Cut Illinois's shapefile

map <- map[map$STATEFP == '17',]


map$value[is.na(map$value) == TRUE] <- 0

ggplot() +
  annotation_spatial(map) +
  layer_spatial(map, aes(fill = value)) +
  scale_fill_gradient(low = "#ffffcc", high = "#ff4444", 
                      space = "Lab", na.value = "grey50",
                      guide = "colourbar")


#12 - 2  leaflet

#leaflet

bins <- c(0, 250000, 750000, 2000000, 4000000, 8000000, Inf)  #Change values #gradient scale
pal <- colorBin("YlOrRd", domain = map$value, bins = bins)  #Change values #color palette

labels <- sprintf(
  "<strong>%s</strong><br>%d Bushels",  #Change values
  map$NAME, round(map$value) #Change values
) %>% lapply(htmltools::HTML)

lf <- leaflet() %>%
  addTiles() %>%
  setView(lng = -100.23, lat = 40.97, zoom = 6) %>%
  addPolygons(data = map,  #Change values
              fillColor = ~pal(value),  #Change values
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))


#add markups


map_fort <- fortify(map, region = "GEOID")  #Change values

distcenters <- map_fort %>%  #Change values
  group_by(id) %>%
  summarise(clat = mean(lat), clong = mean(long))

distcenters <- left_join(distcenters, map@data, by = c("id" = "GEOID"))  #Change values

bins <- c(0, 250000, 750000, 2000000, 4000000, 8000000, Inf)  #Change values
pal <- colorBin("YlOrRd", domain = map$value, bins = bins)  #Change values

labels <- sprintf(
  "<strong>%s</strong><br>%d Bushels",  #Change values
  map$NAME, round(map$value)  #Change values
) %>% lapply(htmltools::HTML)

lf <- leaflet() %>%
  addTiles() %>%
  setView(lng = -100.23, lat = 40.97, zoom = 4) %>%
  addPolygons(data = map,  #Change values
              fillColor = ~pal(value),  #Change values
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

soybean.lf <- lf %>% addMarkers(data = distcenters, ~clong, ~clat, popup = ~as.character(id))  #Change values

soybean.lf

saveWidget(soybean.lf, file="soybean.html")

#12-3 新竹

tw_map <- shapefile("2021TW_SHP/tw_map.shp")

hc_map <- tw_map[tw_map$COUNTY_ID == "10018",]

library(readxl)



hc_income_rank <- read_xlsx('hc_income.xlsx')

hc_income_rank <- hc_income_rank %>%
  mutate(tpp_rate = TPP_2022 / num_voter_2022)


tw_map <- shapefile("2021TW_SHP/tw_map.shp")

hc_map <- tw_map[tw_map$COUNTY_ID == "10018",]

hc_income_rank <- hc_income_rank %>%
  mutate(tpp_rate = TPP_2022 / num_voter_2022)

#we are missing a 0 again. 
hc_income_rank$V_ID <- paste0(substr(hc_income_rank$li_id, 1, 7), "0", substr(hc_income_rank$li_id, 8, 11))

hc_map <- merge(hc_map, hc_income_rank[, c(6, 17:18, 20:22)], by = "V_ID")


#leaflet

bins <- c(0, 0.1, 0.2, 0.3, 0.4, 0.5)  #Change values #gradient scale
pal <- colorBin("YlOrRd", domain = hc_map$tpp_rate, bins = bins)  #Change values #color palette

labels <- sprintf(
  "<strong>%s</strong><br>%s TPP Voting Share",  #Change values
  hc_map$VILLAGE, paste0(round(hc_map$tpp_rate * 100, 2), "%") #Change values
) %>% lapply(htmltools::HTML)

lf <- leaflet() %>%
  addTiles() %>%
  setView(lng = 120.96, lat = 24.81, zoom = 11) %>%
  addPolygons(data = hc_map,  #Change values
              fillColor = ~pal(tpp_rate),  #Change values
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

lf

#add markups


hc_map_fort <- fortify(hc_map, region = "V_ID")  #Change values

hccenters <- hc_map_fort %>%  #Change values
  group_by(id) %>%
  summarise(clat = mean(lat), clong = mean(long))

hccenters <- left_join(hccenters, hc_map@data, by = c("id" = "V_ID"))  #Change values

hccenters <- hccenters %>%
  filter(top10 == 1)

bins <- c(0, 0.1, 0.2, 0.3, 0.4, 0.5)  #Change values #gradient scale
pal <- colorBin("YlOrRd", domain = hc_map$tpp_rate, bins = bins)  #Change values #color palette

labels <- sprintf(
  "<strong>%s</strong><br>%s TPP Voting Share",  #Change values
  hc_map$VILLAGE, paste0(round(hc_map$tpp_rate * 100, 2), "%") #Change values
) %>% lapply(htmltools::HTML)

lf <- leaflet() %>%
  addTiles() %>%
  setView(lng = 120.96, lat = 24.81, zoom = 11) %>%
  addPolygons(data = hc_map,  #Change values
              fillColor = ~pal(tpp_rate),  #Change values
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

lf

top10.lf <- lf %>% addMarkers(data = hccenters, ~clong, ~clat, popup = ~VILLAGE) %>%  #Change values
  addLegend(data = hc_map, pal = pal, values = ~tpp_rate, opacity = 0.7, title = NULL,  #Change values
            position = "bottomright")

top10.lf

saveWidget(top10.lf, file="hc_2022.html")
hc_income_rank$V_ID <- paste0(substr(hc_income_rank$li_id, 1, 7), "0", substr(hc_income_rank$li_id, 8, 11))

hc_map <- merge(hc_map, hc_income_rank[, c(6, 17:18, 20:22)], by = "V_ID")


#leaflet

bins <- c(0, 0.1, 0.2, 0.3, 0.4, 0.5)  #Change values #gradient scale
pal <- colorBin("YlOrRd", domain = hc_map$tpp_rate, bins = bins)  #Change values #color palette

labels <- sprintf(
  "<strong>%s</strong><br>%s TPP Voting Share",  #Change values
  hc_map$VILLAGE, paste0(round(hc_map$tpp_rate * 100, 2), "%") #Change values
) %>% lapply(htmltools::HTML)

lf <- leaflet() %>%
  addTiles() %>%
  setView(lng = 120.96, lat = 24.81, zoom = 11) %>%
  addPolygons(data = hc_map,  #Change values
              fillColor = ~pal(tpp_rate),  #Change values
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

lf

#add markups


hc_map_fort <- fortify(hc_map, region = "V_ID")  #Change values

hccenters <- hc_map_fort %>%  #Change values
  group_by(id) %>%
  summarise(clat = mean(lat), clong = mean(long))

hccenters <- left_join(hccenters, hc_map@data, by = c("id" = "V_ID"))  #Change values

hccenters <- hccenters %>%
  filter(top10 == 1)

bins <- c(0, 0.1, 0.2, 0.3, 0.4, 0.5)  #Change values #gradient scale
pal <- colorBin("YlOrRd", domain = hc_map$tpp_rate, bins = bins)  #Change values #color palette

labels <- sprintf(
  "<strong>%s</strong><br>%s TPP Voting Share",  #Change values
  hc_map$VILLAGE, paste0(round(hc_map$tpp_rate * 100, 2), "%") #Change values
) %>% lapply(htmltools::HTML)

lf <- leaflet() %>%
  addTiles() %>%
  setView(lng = 120.96, lat = 24.81, zoom = 11) %>%
  addPolygons(data = hc_map,  #Change values
              fillColor = ~pal(tpp_rate),  #Change values
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

lf

top10.lf <- lf %>% addMarkers(data = hccenters, ~clong, ~clat, popup = ~VILLAGE) %>%  #Change values
  addLegend(data = hc_map, pal = pal, values = ~tpp_rate, opacity = 0.7, title = NULL,  #Change values
            position = "bottomright")

top10.lf

saveWidget(top10.lf, file="hc_2022.html")
















