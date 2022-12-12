library(lubridate)
library(tidyverse)

# -- DEFINE VARIABLES --
campaign="VP"
dive="DIV4"

# -- LOAD DATA --
#tlog
log<-read.csv(paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_tlog.csv"))
log$Timestamp<-as.POSIXct(log$Timestamp,tz="Europe/Paris")
#sonar
sonar<-read.csv(paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_sonar.csv"))
sonar_info<-file.info(paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,".bin"))
start_time_sonar<-sonar_info$ctime
punix=start_time_sonar+hms(sonar$time)
sonar2<-cbind(sonar,punix)
sonar2<-aggregate(sonar2,by=list(as.character(sonar2$punix)), FUN=tail,n=1)
# merge 
log$Timestamp <- lubridate::ymd_hms(log$Timestamp, tz = "Europe/Brussels")
sonar2$punix <- lubridate::ymd_hms(sonar2$punix, tz = "Europe/Brussels")
log<-inner_join(log, sonar2, by=c("Timestamp" = "punix"))


# -- CREATE NEW NAV FILE --
# define variables
date<-log$clock.currentDate
time<-log$clock.currentTime
latitude<-log$gps.lat
longitude<-log$gps.lon
depth<-log$altitudeRelative*-1 #make positive down
altitude<-log$bathymetry/1000 #convert mm to m
heading<-log$heading
pitch<-log$pitch
roll<-log$roll
#create file
nav.file<-data.frame(date,time,latitude,longitude,depth,altitude,heading,pitch,roll)

#write.csv(nav.file,paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_nav_matisse.csv"),sep=",",quote=FALSE, row.names=FALSE)
write.table(nav.file,paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_nav_matisse.txt"),sep=",",quote=FALSE,row.names=FALSE)
