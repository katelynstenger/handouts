# import US geospatial data
# load data, plot data, extract temp from different protected areas

# inputs:
# shape file of protected areas for usa
# few temperature rasters
# output:
# plots of temperature at intersections


library(raster) # raster functionalities
library(sf) # spatial objects classes
library(lattice)
library(latticeExtra)
library(rasterVis) # raster visualization operations
library(ggplot2)
library(dplyr)

### Define input data file names
# shape data
us_prot_dir <- "~/sample_data/usa_protected_areas"
us_prot <- st_read(
  us_prot_dir,
  stringsAsFactors = FALSE)

st_bbox(us_prot)

# different tiles: US temperature data
# raster data
mean_temp11 <- raster('~/sample_data/mean_annual_temperature/bio1_11.bil')
mean_temp12 <- raster('~/sample_data/mean_annual_temperature/bio1_12.bil')
mean_temp13 <- raster('~/sample_data/mean_annual_temperature/bio1_13.bil')

# projections of shape 
st_crs(us_prot)
prj <- '+proj=aea +lat_1=29.5 +lat_2=45.5 \
    +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0    \
    +ellps=GRS80 +towgs84=0,0,0,0,0,0,0   \
    +units=m +no_defs'


us_prot <- st_transform(
  us_prot,
  crs = prj
)

buffer_us_prot <- st_buffer(us_prot, 1000)

# can filter by type of protected areas
buffer_us_prot %>%
  filter(SUB_LOC =='US-AZ')

# raster projection
crs(mean_temp13)

# back into other projection
buffer_us_prot <- st_transform(
  buffer_us_prot,
  crs = 4326
)

# mean annual temperatures (raster) inside shape files (polygon)
extract(mean_temp12, buffer_us_prot[1,])
sample_temp <- extract(mean_temp12, buffer_us_prot[5:6,], fun = mean)
rownames(sample_temp) <- buffer_us_prot[5:6]

# mask by extent of shape file
mask(mean_temp13, st_bbox(buffer_us_prot))
mask(mean_temp13, extent = c(-120.1, -89, 49))

# plot the
plot(mean_temp12)
plot(buffer_us_prot[5,"PARENT_ISO"], add=T)

# TODO: get everything at the same resolution

state_prot_areas<-buffer_us_prot %>%
  group(SUB_LOC) %>%
  summarize(geometry = st_union(geometry))

extract(mean_temp12, state_prot_areas, fun=mean)
