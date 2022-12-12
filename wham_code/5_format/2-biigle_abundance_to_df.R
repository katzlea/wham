library(tidyverse)
library(data.table)
library(readxl)

campaign="B121"

# --- MAKE A DF FROM ALL ANNOTATIONS ---

dir<-paste0("wham_data/",campaign,"/biigle/abundance")
import<-list.files(dir) 

for (i in 1:length(import)) {
  file<-read_xlsx(paste0(dir,"/",import[i]))
  dive<-colnames(file)[1]
  names(file)<-as.character(unlist(file[1,]))
  x <- file[-1,]
  x["dive"]=paste0(dive)
  #save(x,file=paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_abundance.RData")) #1 file per dive
  if (i == 1) {mydata<-x} else {mydata<-bind_rows(mydata,x)}
}
mydata<-mydata %>% relocate(dive)
mydata[3:ncol(mydata)]<-sapply(mydata[3:ncol(mydata)],as.numeric)
mydata[is.na(mydata)] = 0 #turn NA into 0


save(mydata,file=paste0("wham_data/",campaign,"/",campaign,"_abundance.RData"))

