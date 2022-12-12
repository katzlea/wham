library(readxl)
library(dplyr)
library(reshape2)

campaign="B121"

# _________________________________________________________________
# rename all files in dir
#area
dir<-paste0("wham_data/",campaign,"/biigle/area")
files<-list.files(dir)

for (i in 1:length(files)) {
  file<-read_xlsx(paste0(dir,"/",files[i]))
  dive<-colnames(file)[1]
  newname<-paste0(campaign,"_",dive,"_area.xlsx")
  file.rename(paste0("wham_data/",campaign,"/biigle/area/",files[i]),paste0("wham_data/",campaign,"/biigle/area/",newname))
}

#abundance
dir<-paste0("wham_data/",campaign,"/biigle/abundance")
files<-list.files(dir)

for (i in 1:length(files)) {
  file<-read_xlsx(paste0(dir,"/",files[i]))
  dive<-colnames(file)[1]
  newname<-paste0(campaign,"_",dive,"_abundance.xlsx")
  file.rename(paste0("wham_data/",campaign,"/biigle/abundance/",files[i]),paste0("wham_data/",campaign,"/biigle/abundance/",newname))
}
# _________________________________________________________________


### _________________________________________________________________
### _______________ ADD AREA TO ANNOTATIONS _________________________
### CHOOSE : FOR 1 DIVE OR FOR ALL ANNOTATED DIVES IN CAMPAIGN FOLDER
### _________________________________________________________________

### _____ FOR 1 DIVE _____
dive="Example_dive"

# load data
area<-read_xlsx(paste0("wham_data/",campaign,"/biigle/area/",campaign,"_",dive,"_area.xlsx"))
abundance<-read_xlsx(paste0("wham_data/",campaign,"/biigle/abundance/",campaign,"_",dive,"_abundance.xlsx"))

# reformatting
source("wham_code/functions/headertrue.R")
area<-header.true(area)
abundance<-header.true(abundance)
a2<-dcast(abundance,image_filename~label_hierarchy)
source("wham_code/functions/rownamestrue.R")
a3<-rownames.true(a2)

# add relative cover (only for "rock" now...)
area$cover<-NA
ar2<-NA
for (u in 1:length(unique(area$image_filename))) {
  unique(area$image_filename)[u]->image
  image_a<-subset(area,image_filename==image)
  if ("Rock" %in% image_a$label_names) {
    total<-image_a$annotation_area_sqpx[image_a$label_names=="Rock"]
  } else {total=NA}
  image_a$cover<-(as.numeric(image_a$annotation_area_sqpx)*100)/as.numeric(total)
  ar2<-rbind(ar2,image_a)
}

# sum of same species cover for each image
sum<-ar2 %>% group_by(image_filename, label_names) %>% summarize(cover = sum(cover))

# add to abundance
a2<-as.matrix(a2)
m <- a2[,-1]
rownames(m) <- a2[,1]

for (x in 1:nrow(sum)) {
  i <- sum$image_filename[x]
  j <- sum$label_names[x]
  m[i,j]<-sum$cover[x]
}


save(m,paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_abundance.R"))



############################################################################################
# WORK IN PROGRESS
############################################################################################

### ___________________________________________________
### _____ FOR ALL ANNOTATED DIVES OF THE CAMPAIGN _____

dir1<-paste0("wham_data/",campaign,"/biigle/abundance")
dir2<-paste0("wham_data/",campaign,"/biigle/area")
files1<-list.files(dir1)
files2<-list.files(dir2)

for (i in 1:length(files)) {
  #load
  abundance<-read_xlsx(paste0("wham_data/",campaign,"/biigle/abundance/",files1[i]))
  area<-read_xlsx(paste0("wham_data/",campaign,"/biigle/area/",files2[i]))
  #remove auto-generated title
  source("wham_code/functions/headertrue.R")
  area<-header.true(area)
  abundance<-header.true(abundance)
  
  
  # continue from here
  
  # using sqpx area
  total<-480961798.3669 
  cover<-(as.numeric(area$annotation_area_sqpx)*100)/total
  area<-cbind(area,cover)
  
  # sum of same species cover for each image
  sum<-area %>% group_by(image_filename, label_names) %>% summarize(cover = sum(cover))
  
  # add to abundance
  abundance<-as.matrix(abundance)
  m <- abundance[,-1]
  rownames(m) <- abundance[,1]
  
  for (x in 1:nrow(sum)) {
    i <- sum$image_filename[x]
    j <- sum$label_names[x]
    m[i,j]<-sum$cover[x]
  }
  
  
  save(m,paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_abundance.R"))
}


# extras
algae<-m[,1:5] #subset algae only => to replace values with cover
#animalia<-m[,6:ncol(m)] #subset animals only 
algae<-as.data.frame(algae)
algae[] <- lapply(algae, as.integer)


save(algae,file="data/algae_cover_DIV27.RData")
