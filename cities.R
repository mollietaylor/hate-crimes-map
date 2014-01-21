library(rgdal)

# import city coordinate data:
# source: http://geonames.usgs.gov/domestic/download_data.htm
coords <- read.csv("cities-coords.csv",
  header = TRUE,
  sep = "|")

# get rid of village, city, town, and township:
coords$FEATURE_NAME <- sub("Village of ", "", coords$FEATURE_NAME, fixed = TRUE)
coords$FEATURE_NAME <- sub("City of ", "", coords$FEATURE_NAME, fixed = TRUE)
coords$FEATURE_NAME <- sub("Town of ", "", coords$FEATURE_NAME, fixed = TRUE)
coords$FEATURE_NAME <- sub("Township of ([A-Za-z ]+)", "\\1 Township", coords$FEATURE_NAME, fixed = FALSE)


# limit data from file to only cities:
coords <- coords[coords$FEATURE_CLASS == "Populated Place" | coords$FEATURE_CLASS == "Civil",]
coords <- coords[,c(1, 3:5)]

names(coords) <- c("City", "State", "Latitude", "Longitude")

# coordinates not in original data:
extraCoords <- read.csv("extra-coords.csv",
  header = TRUE,
  sep = "\t")

coords <- rbind(coords, extraCoords)

# import hate crimes data:
# source: http://www.splcenter.org/get-informed/hate-incidents
hate <- read.csv("hate-incidents.csv",
  header = TRUE,
  sep = ",")

# merge hate & cities by city & state:
hateCoords <- merge(coords, hate, 
  by= c("City", "State"),
  all.x = FALSE,
  all.y = TRUE)

# find cities without coordinates:
temp <- hateCoords[!complete.cases(hateCoords[,c(4,3)]),]

# remove cities without coordinates:
hateCoords <- hateCoords[complete.cases(hateCoords[,c(4,3)]),]

# convert to SpatialPointsDataFrame:
hateCoordsSP <- SpatialPointsDataFrame(hateCoords[,c(4,3)], hateCoords[,-c(4,3)])

# export:
writeOGR(hateCoordsSP, "hateCoords.geojson","hateCoordsSP", driver = "GeoJSON")


# only crimes:
  crimes <- hateCoords[hateCoords$Type != "Legal Developments",]
  crimesSP <- SpatialPointsDataFrame(crimes[,c(4,3)], crimes[,-c(4,3)])
  writeOGR(crimesSP, "crimes.geojson","crimesSP", driver = "GeoJSON")


# only legal developments:
  developments <- hateCoords[hateCoords$Type == "Legal Developments",]
  devSP <- SpatialPointsDataFrame(developments[,c(4,3)], developments[,-c(4,3)])
  writeOGR(devSP, "developments.geojson","devSP", driver = "GeoJSON")

