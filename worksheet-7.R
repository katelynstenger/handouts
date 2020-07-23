## Vector Data

library(sf)

# OSGeo Dependencies
# GDAL
# GEOS
# PROJ.4


shp <- 'data/cb_2016_us_county_5m'
counties <- st_read(
    shp,
    stringsAsFactors = FALSE)

sesync <- st_sfc(
    st_point(c(-76.503394, 38.976546)),
    crs = st_crs(counties))

# st_crs(counties) (Coordinate Reference System)
# prints spatial object

## Bounding box
# st_bbox(counties)
# bounding box for all features in sf dataframe


library(dplyr)
counties_md <- filter(
    counties,
    STATEFP =='24' #maryland
)

# bounding box
st_bbox(counties_md)

## Grid
st_crs(st_bbox(counties_md))

# rectangular grid over a sf object
grid_md <- st_make_grid(counties_md,
                        n = 4)
# response to error: earth's curvature can be ignored

## Plot Layers

plot(grid_md)
plot(counties_md['ALAND'],
     add = TRUE) #allows additional plots
plot(sesync, col = "green",
     pch = 20, add = TRUE) # col & pch graphical parameters

# matching within 
st_within(sesync, counties_md)

# st_intersects	boundary or interior of x intersects boundary or interior of y
# st_within	    interior and boundary of x do not intersect exterior of y
# st_contains	y is within x
# st_overlaps	interior of x intersects interior of y
# st_equals	    x has the same interior and boundary as y


## Coordinate Transforms
# st_read is a data.frame

shp <- 'data/huc250k'
huc <- st_read(
    shp,
    stringsAsFactors = FALSE)

st_crs(counties_md)$proj4string
st_crs(huc)$proj4string


# huc is an Albers equal-area projection "+proj=area"
# census uses unprojected (lat & longitude) coordinates

# st_transform converts an sfc between coordinate reference
# specified the parameter crs = x
# where x is a numerically valid EPSG code, interpreted as a PROJ.4 string


# assign 2 layers & SESYNC's location to a common projection strung (prj)
prj <- '+proj=aea +lat_1=29.5 +lat_2=45.5 \
    +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0    \
    +ellps=GRS80 +towgs84=0,0,0,0,0,0,0   \
    +units=m +no_defs'

counties_md <- st_transform(
    counties_md,
    crs=prj)
huc <- st_transform(huc, crs=prj)
sesync <- st_transform(
    sesync,
    crs = prj
)

plot(counties_md$geometry)
plot(huc$geometry,
     border = 'blue', add = TRUE)
plot(sesync, col = 'green',
     pch = 20, add = TRUE)

## Geometric Operations

state_md <- st_union(counties_md)
plot(state_md)

huc_md <- st_intersection(
    huc, 
    state_md)

plot(state_md)
plot(huc_md, border = 'blue',
     col = NA, add = TRUE)

# st_intersection intersects first arg with 2nd arg
# anything beyond the first arg is cut
# the area (or anything else) with df doesn't change

# GEOS library provides many functions through sf
# st_buffer:    to create a buffer of specific width around a geometry
# st_distance:  to calculate the shortest distance between geometries
# st_area:      to calculate the area of polygons
# all use PLANAR geometry equations
# to calc with geodesic distane: 
# geosphere package


## Raster Data

library(raster)
nlcd <- raster("data/nlcd_agg.grd")

## Crop

extent <- matrix(st_bbox(huc_md), nrow=2)
nlcd <- crop(nlcd, extent)
plot(nlcd)
plot(huc_md, col = NA, add = TRUE)



## Raster data attributes
# raster is a data matrix
# individual pixel values can be extracted by reg matrix subscripting
nlcd[1,1]
# looking at data attributes
# '@' operator used to access properties of an object
# known as "slots"
head(nlcd@data@attributes[[1]])

nlcd_attr <- nlcd@data@attributes 
lc_types <- nlcd_attr[[1]]$Land.Cover.Class

levels(lc_types)

## Raster math

pasture <- mask(nlcd, nlcd == 81,
    maskvalue = FALSE)
plot(pasture)

# mask function with logical condition
# this results in a raster where all pixels
# not classified as pasture are removed

# futher reduce the resolution of nlcd raster
# aggregate(), 
# where fact = 25 means 25 X 25 pixels
# fun=modal indicates aggregate value is the mode of the original pixels
# averaging wouldn't work bc categorical variable
nlcd_agg <- aggregate(nlcd,
    fact = 25,
    fun = modal)
nlcd_agg@legend <- nlcd@legend
plot(nlcd_agg)

## Mixing rasters and vectors
# raster package tight with sp package & hasn't caught up to sf package
# stars package aim to remedy problem (in dev)
# terra package integrate with sf may work (in dev)


# Convert a vector object from sf to sp
# sp_object <- as (sf_object, 'Spatial')

plot(nlcd)
plot(sesync, col = 'green',
     pch = 16, cex = 2, add = TRUE)

# extract a point
sesync_lc <- extract(nlcd, st_coordinates(sesync))
lc_types[sesync_lc +1]

# extract with a polygon
county_nlcd <- extract(nlcd_agg,
                       counties_md[1,])
table(county_nlcd)

# summary of raster values for each polygon
# fun = modal gives most common land cover for each polygon in huc_md
modal_lc <- extract(nlcd_agg,
                    huc_md, fun = modal)
huc_md <- huc_md %>%
    mutate(modal_lc = lc_types[modal_lc +1])
huc_md

## Leaflet
# interactive maps

library(leaflet)
leaflet() %>%
    addTiles() %>%
    setView(lng = -77, lat = 39, 
        zoom = 7)

# lat/lon coordinates EPSG:4326
leaflet() %>%
    addTiles() %>%
    addPolygons(
        data = st_transform(huc_md, 4326)) %>%
    setView(lng = -77, lat = 39, 
        zoom = 7)

# Web mapping services (WBS)
leaflet() %>%
    addTiles() %>%
    addWMSTiles(
        "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
        layers = "nexrad-n0r-900913", group = "base_reflect",
        options = WMSTileOptions(format = "image/png", transparent = TRUE),
        attribution = "weather data © 2012 IEM Nexrad") %>%
    setView(lng = -77, lat = 39, 
        zoom = 7)

# use the map controls to zoom away from the current location
# more in-depth tutorial: https://cyberhelp.sesync.org/leaflet-in-R-lesson/


# More packages to try out:
# exactextractr:quickly summarizes rasters across polygons
# rasterVis:    supplements the raster package for improved visualizations
# velox:        fast raster extraction still in development on GitHub

# Exercise 1 
# produce a map of MD counties with the county that contains SESYNC colored in RED
plot(counties_md$geometry)
overlay	<- st_within(sesync, counties_md)
counties_sesync <- counties_md[overlay[[1]], 'geometry']
plot(counties_sesync, col = "red", add = TRUE)
plot(sesync, col = 'green', pch = 20, add = TRUE)

# Exercise 2
# Use st_buffer to create a 5km buffer around the state_md
# border and plot it as a dotted line over the true state border
# check the layer's units with st_crs()
bubble_md <- st_buffer(state_md, 5000)
plot(state_md)
plot(bubble_md, lty = 'dotted', add =TRUE)

# Exercise 3
# use cellStats to aggregate across a raster &
# figure out the proportion of nlcd pixels covered
# by deciduous forest (value = 41)

cellStats(nlcd ==41, mean)
