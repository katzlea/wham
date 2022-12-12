library(tidyverse)
source("wham_code/functions/headertrue.R")

campaign="B121"

# ---------------------------------------------------------------------------------------------
# --- FOR JUST 1 DIVE
dive="DIV10_NekoHarbour"
biigle<-read.csv(paste0("wham_data/",campaign,"/biigle/abundance/",campaign,"_",dive,".csv"))
area<-read_excel(paste0("wham_data/",campaign,"/biigle/area/",campaign,"_",dive,"_area.xlsx"))

area<-header.true(area)

area<- area %>% select(annotation_id,annotation_area_sqm,annotation_area_sqpx) %>% mutate_if(is.character,as.numeric) 
biigle<-left_join(biigle,area,by="annotation_id")

save(biigle,file=paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_biigle.RData"))

# ---------------------------------------------------------------------------------------------
# --- CREATE 1 BIG DATA FRAME FOR ALL DIVES