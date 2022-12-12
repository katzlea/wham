library(bnlearn)

campaign="B121"

#---- LOAD DATA
load(paste0("wham_data/",campaign,"/",campaign,"_abundance.RData"))
load(paste0("wham_data/",campaign,"/",campaign,"_metadata.RData"))

#------------------------------------------------------------------------------------
## ABUNDANCE => PRESENCE/ABSENCE (2 levels)
mydata->discr
discr[,3:ncol(discr)]<-lapply(discr[,3:ncol(discr)],function(x) ifelse(x==0,0,1))
discr[,1:ncol(discr)]<-lapply(discr[,1:ncol(discr)],function(x) as.factor(x))
# REMOVE VARIABLES WITH ONLY ZERO
discr<-discr[,sapply(discr, nlevels) > 1]

# CHECK DISTRIBUTION OF PRESENCE/ABSENCE
gg_melt <- pivot_longer(discr,3:ncol(discr),names_to="species")
ggplot(gg_melt, aes(value)) +
  geom_bar(stat="count") +
  scale_x_discrete(labels = c("0" = "0", "1" = "1")) + 
  facet_wrap(~species)

# Look at the plot. 
# If taxa has mostly absence : group together with similar taxa.
# If taxa has mostly presence : try adding more levels when discretizing

#_________________________________________
## ABUNDANCE => ABSENT/LOW/HIGH (3 levels)
source("wham_code/functions/get.hilo.R")
discr$`Iridaea cordata`<-as.factor(get.hilo(mydata$`Iridaea cordata`))
# go back to "check distribution" and make gg_melt again.
#________________________________________
## GROUP TAXA TOGETHER
# sea stars except odon.val
starfish_list<-c("Asteroidea","Labidiaster annulatus")
starfish<-mydata[,starfish_list]
starfish<-rowSums(starfish)
discr$starfish<-as.factor(ifelse(starfish==0,0,1))

# go back to "check distribution" and make gg_melt again.
# if satisfied : remove grou
final<-discr[ , !(names(discr) %in% starfish_list)]
#________________________________________





#---------------------------------------------------------------------
#---------------------------------------------------------------------
# COMPILE THE FINAL DATASET FOR NEXT STEP
#---------------------------------------------------------------------

#---- METADATA => FACTORS
env[,1:ncol(env)]<-lapply(env[,1:ncol(env)],function(x) as.factor(x))

#---- MERGE ENV DATA WITH ABUNDANCE
mydata<-inner_join(final,env,by="dive")

#---- SAVE
save(mydata,file=paste0("wham_data/",campaign,"/",campaign,"_bni.RData"))











##### BROUILLON

## ADD EXCEPTIONS (the ones with 3 levels)
#---- ABUNDANCE => ABSENT/LOW/HIGH (3 levels)
source("wham_code/functions/get.hilo.R")
irid.cor<-get.hilo(mydata$`Iridaea cordata`)

mydata$irid.cor<-irid.cor %>% as.factor()

## METADATA => FACTORS
drops<-c("image","transect") #choose columns to remove
#drops<-c("image","transect","region.code") #if data from only 1 region

mydata<-mydata[ , !(names(mydata) %in% drops)] #removes unnecessary columns
mydata$substrate<-as.factor(mydata$substrate)
mydata$region.code<-as.factor(mydata$region.code)
mydata$max_depth<-as.factor(mydata$max_depth)

## REMOVE VARIABLES WITH ONLY ZERO
mydata<-mydata[, sapply(mydata, nlevels) > 1]

## SAVE
#save(mydata,file="mydata_1_discr.RData")
#save(mydata,file="mydata_loc_discr.RData")
save(mydata,file="mydata_loc_gr_discr.RData")
#save(mydata,file="mydata_UI_gr_discr.RData")


## SUBSTRATE : make scale for substrate (soft=>hard)
unique(mydata$substrate) #find out what the different labels are
for (i in c(1:854)) {
  if (mydata$substrate[i]=="s") {1 -> mydata$substrate[i]} 
  else if (mydata$substrate[i]=="s+g"|mydata$substrate[i]=="s+u") {2 -> mydata$substrate[i]} 
  else if (mydata$substrate[i]=="s+r") {3 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="s+b") {4 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="g+s"|mydata$substrate[i]=="u+s") {5 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="g"|mydata$substrate[i]=="u"|mydata$substrate[i]=="u+g"|mydata$substrate[i]=="g+u") {6 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="g+r"|mydata$substrate[i]=="u+r") {7 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="g+b"|mydata$substrate[i]=="u+b") {8 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="r+s") {9 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="r+g"|mydata$substrate[i]=="r+u") {10 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="r") {11 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="r+b") {12 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="b+s") {13 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="b+g"|mydata$substrate[i]=="b+u") {14 ->mydata$substrate[i]}
  else if (mydata$substrate[i]=="b+r") {15 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="b") {16 -> mydata$substrate[i]}
  else if (mydata$substrate[i]=="x") {17 -> mydata$substrate[i]}
} 
mydata$substrate<-as.numeric(mydata$substrate)






# --- SUBSET PER DIVE
dive="DIV23_Hovgaard"
mydive<-mydata[grep(dive,mydata$dive),]
mydive<-mydive[,-1]

save(mydive,file=paste0("wham_data/",campaign,"/",dive,"/",campaign,"_",dive,"_bni1.RData"))
