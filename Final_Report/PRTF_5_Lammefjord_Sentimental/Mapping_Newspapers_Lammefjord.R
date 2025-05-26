library(tidyverse)
library(googlesheets4)
library(leaflet)
library(htmlwidgets)

gs4_deauth() #just to make sure the spreadsheet is accessible

#reading in the sheet
Newspapers_Unique <- read_sheet("https://docs.google.com/spreadsheets/d/1yBqisqe8oF5PEJI3_Rlo1cgRaR84rKHmhJFgNzfkQc4/edit?gid=0#gid=0",
                     col_types = "ccnnc",range = "Ark1")

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

Maps_Newspapers_final <- Maps_Newspapers_esri %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = T)) %>% #adds layer controls
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>% #adds minimap
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
  addControl("", position = "topright")%>%
  addMarkers(lng=Newspapers_Unique$Longtitude,
             lat=Newspapers_Unique$Latitude,
             popup=paste(Newspapers_Unique$Newspaper),clusterOptions = markerClusterOptions())

Maps_Newspapers_final

saveWidget(Maps_Newspapers_final, "Maps_Newspapers.html", selfcontained = TRUE)
