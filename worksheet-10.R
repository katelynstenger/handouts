# Documenting and Publishing your Data Worksheet


# - Create metadata locally
# - build data package locally
# - learn data versioning 
# - practice uploading data package to repo

# data package: collection of files describe data
# data & metadata

# Preparing Data for Publication
library(tidyverse)

stm_dat <- read_csv("../data/StormEvents.csv")

head(stm_dat)
tail(stm_dat)

str(stm_dat$EVENT_NARRATIVE) 
unique(stm_dat$EVENT_NARRATIVE) 

dir.create('storm_project', showWarnings = FALSE)
write_csv(stm_dat, "storm_project/StormEvents_d2006.csv")


## Metadata
# it is info needed for someone else to understand & use data
# who, what, when, where, why & how of data
# find the standard for the field

# dataspice: not in CRAN
# devtools::install_github("ropenscilabs/dataspice")

# Creating metadata
library(dataspice)
library(jsonlite)

create_spice(dir = "storm_project")

# Describe the package-level metadata
# can gather temporal & spatial extent info using range()
range(stm_dat$YEAR)
range(stm_dat$BEGIN_LAT, na.rm=TRUE)
range(stm_dat$BEGIN_LON, na.rm=TRUE)

# Save info in CSV templates
edit_biblio(metadata_dir = "storm_project/metadata")

edit_creators(metadata_dir = "storm_project/metadata")


prep_access(data_path = "storm_project",
            access_path = "storm_project/metadata.csv")
edit_access(metadata_dir = "storm_project/metadata.csv")

prep_attributes(data_path = "storm_project",
                attributes_path = "storm_project/metadata/attributes.csv")  

edit_attributes(metadata_dir = "storm_project/metadata")


# Write metadata file, json-ld file
write_spice(path = "storm_project/metadata")

# static website for dataset
build_site(path = "storm_project/metadata/dataspice.json")

library(emld) ; library(EML) ; library(jsonlite)

json <- read_json("storm_project/metadata/dataspice.json")
eml <- as_emld(json)  
write_eml(eml, "storm_project/metadata/dataspice.xml")

# Creating a data package

# can use Frictionless Data & datapackage.r
# Can use DataONE, datapack.r & dataone.r
library(datapack) ; library(uuid)

dp <- new("DataPackage") # create empty data package

emlFile <- "storm_project/metadata/dataspice.xml"
emlId <- paste("urn:uuid:", UUIDgenerate(), sep = "")

mdObj <- new("DataObject", id = emlId, format = "eml://ecoinformatics.org/eml-2.1.1", file = emlFile)

dp <- addMember(dp, mdObj)  # add metadata file to data package

# add data file we save earlier to data package
datafile <- "storm_project/StormEvents_d2006.csv"
dataId <- paste("urn:uuid:", UUIDgenerate(), sep = "")

dataObj <- new("DataObject", id = dataId, format = "text/csv", filename = datafile) 

dp <- addMember(dp, dataObj) # add data file to data package

# define the relationships
dp <- insertRelationship(dp, subjectID = emlId, objectIDs = dataId)

# create a Resource Description Framework (RDF) of the relationships bt data & metadata
serializationId <- paste("resourceMap", UUIDgenerate(), sep = "")
filePath <- file.path(sprintf("%s/%s.rdf", tempdir(), serializationId))
status <- serializePackage(dp, filePath, id=serializationId, resolveURI = "")

# save data package to file using BagIt packaging format
dp_bagit <- serializeToBagIt(dp) 
file.copy(dp_bagit, "storm_project/Storm_dp.zip") 

# this is a static copy of the DataONE member nodes as of July, 2019
read.csv("data/Nodes.csv")


## Picking a repo

# re3data lists repos by subject
# DataONE 
# Knowledge Network for Biocomplexity 
# Environmental Data Initiative
# Dryad, USGS Science Data Catalog

# Qualitative data: 
# QDR, Data-PASS
# Zenodo



