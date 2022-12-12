library(spatstat)
library(sf)
library(rgdal)
library(rgeos)
library(shapefiles)
library(ggplot2)
library(ggspatial)

campaign="Example_campaign"
dive="Example_dive"

# -------------------------------------------------------------------
## PREPARE DATASET FOR SPPA
# -------------------------------------------------------------------

# import data
shapes<-readOGR(paste0("wham_data/",campaign,"/biigle/shp/",campaign,"_",dive,".shp"))
dbf<-read.dbf(paste0("wham_data/",campaign,"/biigle/shp/",campaign,"_",dive,".dbf"))

# find centroids of polygons (convert shapes to points)
points<-gCentroid(shapes,byid=T)
coord<-coordinates(points)

# make a point pattern
mypattern<-ppp(points@coords[,1], 
               points@coords[,2], 
               c(points@bbox[1,1],points@bbox[1,2]), #for x in range 100-200
               c(points@bbox[2,1],points@bbox[2,2]), #for y in range 10-90
               marks = dbf$dbf
               )  


# -------------------------------------------------------------------
## VISUALISE DATASET
# -------------------------------------------------------------------

# only shapes
plot(shapes)

esri_ocean <- paste0('https://services.arcgisonline.com/arcgis/rest/services/',
                     'Ocean/World_Ocean_Base/MapServer/tile/${z}/${y}/${x}.jpeg')
# more options in :
# https://jmlondon.github.io/solamac-spatial-mapping/exercise-1-loading-spatial-data.html

ggplot() + 
  #annotation_map_tile(type=esri_ocean,progress="none") +
  layer_spatial(
    shapes,
    fill=NA,
    size=1,
    aes(color=X_label_id)
    ) +
  annotation_scale(
    location="br",
    width_hint=0.5,
    style="ticks"
    ) +
  theme_light() +
  ggtitle(
    paste0(campaign," ",dive),
    subtitle="Species cover"
    )

# point pattern
plot(mypattern,which.marks="X_label_id")

ggplot() +
  layer_spatial(
    mypattern,
    aes(color=X_label_id)
    )


# -------------------------------------------------------------------
## OPERATIONS/STATISTICS
# -------------------------------------------------------------------

# --- stats
summary(mypattern)
plot(Kest(mypattern)) #Ripley's K-function
plot(envelope(mypattern,Kest)) #envelopes of K-function
plot(density(mypattern)) #kernel smoother of point density

# --- add marks
marks(mypattern)<-mydata[,c(5,9)] #for ex columns 5 and 9 contain height & sex
plot(Smooth(mypattern))
plot(mydata,
     which.marks="variable",
     cols=2:5, #colors
     chars=1:4) #characters
