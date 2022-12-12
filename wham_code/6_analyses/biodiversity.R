library(vegan)
library(tidyverse)
library(reshape2)
library(pals)
#------------------------------------------------------------------------------
#creating a large color palette for all the species
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
#------------------------------------------------------------------------------

campaign="B121"

##########################################################################
# --- COMMUNITY COMPOSITION  ---
##########################################################################

load(paste0("wham_data/",campaign,"/",campaign,"_summary.RData")) #grouped by dive

#stacked barplot (counting specimens)
ggplot(melt(mydata), aes(x=dive, y=value, fill=variable)) +
  geom_bar(position="stack",stat="identity") +
  labs (x="site",y="# of individuals",title="Community composition") +
  theme_light() +
  theme(axis.text.x = element_text(angle=90)) +
  scale_fill_manual(values=sample(col_vector,nlevels((melt(mydata))$variable)))

#stacked barplot (relative abundance)
ggplot(melt(mydata), aes(x=dive, y=value, fill=variable)) +
  geom_bar(position="fill",stat="identity") +
  labs (x="site",y="relative abundance",title="Community composition") +
  theme_light() +
  theme(axis.text.x = element_text(angle=90)) +
  scale_fill_manual(values=sample(col_vector,nlevels((melt(mydata))$variable)))

##########################################################################
# --- VEGAN FUNCTIONS ---
##########################################################################

#_________________________________________________________________________
## SPECIES RICHNESS

load(paste0("wham_data/",campaign,"/",campaign,"_summary.RData")) #grouped by dive
SN<-specnumber(mydata)
mydata$SN<-SN

#barplot of Species Richness
ggplot(mydata, aes(dive,SN,fill=dive)) +
  geom_col() +
  labs (x="site",y="species number") +
  theme_light() +
  theme(axis.text.x = element_text(angle=90))
  
#lollypop chart
mydata %>%
  mutate(dive=fct_reorder(dive,SN)) %>%
  ggplot(aes(x=dive,y=SN)) +
  geom_bar(stat="identity",fill="pink") +
  coord_flip() +
  theme_light() +
  labs(x="",y="Number of species")

#_________________________________________________________________________
## ALPHA DIVERSITY

load(paste0("wham_data/",campaign,"/",campaign,"_abundance.RData")) #all images
alpha<-diversity(mydata[3:ncol(mydata)]) #shannon
mydata$alpha<-alpha

#boxplot of alpha diversity
ggplot(mydata, aes(dive,alpha)) +
  geom_boxplot() +
  theme_light() +
  theme(axis.text.x = element_text(angle=90))

#anova of alpha diversity
anova_result <- aov(alpha ~ dive, mydata)
summary(anova_result)

#_________________________________________________________________________
## BETA DIVERSITY

load(paste0("wham_data/",campaign,"/",campaign,"_abundance.RData")) #grouped by dive
beta<-vegdist(mydata[3:ncol(mydata)], index= "bray")
mds<-metaMDS(beta)
mds_data<-as.data.frame(mds$points)
mds_data <- cbind(mds_data, mydata)
ggplot(mds_data,aes(MDS1,MDS2,color=dive)) +
  geom_point()









###### WORK IN PROGRESS

# Beta diversity
ncol(mydata)/mean(specnumber(mydata)) - 1
beta <- vegdist(mydata[2:ncol(mydata)], binary=TRUE)
mean(beta)
betadiver(help=TRUE)
b<-betadiver(mydata,"sor")


## Results on a map

# with mapview (en cours)
biodiv<-merge(mydata,transects,by.x="region.code",by.y="region_code",all.y=FALSE) 
source("format/dms_to_dec.R")
biodiv$long<-dm_to_dec(biodiv$long,type="dm")
biodiv$lat<-dm_to_dec(biodiv$lat,type="dm")

#bio_sf<-st_as_sf(biodiv, coords = c("long","lat"), rs=4326) #ne fonctionne pas, il ne reconnait pas de geometrie
#mapview(bio_sf)


# for Qgis
qgis<-bind_cols(maps,H)
colnames(qgis)[40] <- "H"

qgis<-bind_cols(qgis,J)
colnames(qgis)[41] <- "J"

qgis<-bind_cols(qgis,SN)
colnames(qgis)[42] <- "SN"

save(qgis,file="data/mydata_qgis.RData")
load("data/mydata_qgis.RData")
write.table(newdata,"outputs/mydata_qgis.txt")



