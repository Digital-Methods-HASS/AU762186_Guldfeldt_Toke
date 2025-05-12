library(tidyverse)
library(googlesheets4)
library(leaflet)
library(htmlwidgets)

gs4_deauth() #just to make sure the spreadsheet is accessible

#reading in the sheet
places <- read_sheet("https://docs.google.com/spreadsheets/d/1QsggUjP7ibnFhjCAClcLKAJ2VwMdgdAhLV8p9xpgQcA/edit?gid=0#gid=0",
                     col_types = "ccnnc",range = "Ark1")

glimpse(places)

#making a basic map
Maps_Newspapers <- leaflet()%>%
  addTiles()%>%
  addMarkers(lng=places$Longtitude,
             lat=places$Latitude,
             popup=paste(places$Avis))
Maps_Newspapers

saveWidget(Maps_Newspapers, "Maps_Newspapers.html", selfcontained = TRUE)
