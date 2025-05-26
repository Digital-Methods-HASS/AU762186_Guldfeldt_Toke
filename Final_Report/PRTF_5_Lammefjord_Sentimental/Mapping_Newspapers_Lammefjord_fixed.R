library(tidyverse)
library(googlesheets4)
library(leaflet)
library(htmlwidgets)

gs4_deauth() #just to make sure the spreadsheet is accessible

#reading in the sheet
Newspapers_Unique <- read_sheet("https://docs.google.com/spreadsheets/d/1yBqisqe8oF5PEJI3_Rlo1cgRaR84rKHmhJFgNzfkQc4/edit?gid=0#gid=0",
                     col_types = "ccnnc",range = "Ark1")

glimpse(Newspapers_Unique)

#incase google spreadsheet is unavailable, remove the hashtag from line 15
#Newspapers_Unique <- read_csv("data/Newspapers_Places_Unique - Ark1.csv")
glimpse(Newspapers_Unique)

#making a basic map
Maps_Newspapers_Unique <- leaflet()%>%
  addTiles()%>%
  addMarkers(lng=Newspapers_Unique$Longtitude,
             lat=Newspapers_Unique$Latitude,
             popup=paste(Newspapers_Unique$Newspaper))
Maps_Newspapers_Unique

# adding esri to the map
esri <- grep("^Esri", providers, value = TRUE)

for (provider in esri) {
  Maps_Newspapers_esri <- Maps_Newspapers_Unique %>% addProviderTiles(provider, group = provider)
}

#making a prettier map with esri and clustered popups
Newspapers_Unique <- read_sheet("https://docs.google.com/spreadsheets/d/1yBqisqe8oF5PEJI3_Rlo1cgRaR84rKHmhJFgNzfkQc4/edit?gid=0#gid=0",
                                col_types = "ccnnc",range = "Ark1")


Maps_Newspapers_cluster <- leaflet()%>%
  addTiles()%>%
  addMarkers(lng = Newspapers_Unique$Longtitude,
             lat = Newspapers_Unique$Latitude,
             popup = paste(Newspapers_Unique$Newspaper), clusterOptions = markerClusterOptions(freezeAtZoom = FALSE))

for (provider in esri) {
  Maps_Newspapers_cluster <- Maps_Newspapers_cluster %>% addProviderTiles(provider, group = provider)
}

Maps_Newspapers_clustered <- Maps_Newspapers_cluster %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright")

Maps_Newspapers_clustered

#saveWidget(Maps_Newspapers_clustered, "Maps_Newspapers_final.html", selfcontained = TRUE)
