library(vegan)
library(tidyverse)


campaign="Example_campaign"

# ------------------------------------------------------------------------
load(paste0("wham_data/",campaign,"/",campaign,"_abundance.RData"))
# ------------------------------------------------------------------------

##########################################################################
# --- NON-METRIC MULTIDIMENSIONAL SCALING ---
##########################################################################

# turning into a matrix, make image name into row name
mydata_m<-as.matrix(data.frame(mydata,row.names=2))
m<-mydata_m[,2:ncol(mydata_m)]
class(m)<-"numeric"

# nmds
nmds<-metaMDS(m) #add "k=..." for n of reduced dimensions

# extract data
image.scores<-as.data.frame(scores(nmds)$sites)
image.scores$image<-row.names(image.scores)
species.scores<-as.data.frame(scores(nmds)$species)
species.scores$species<-row.names(species.scores)

# plot
plot(nmds)
stressplot(nmds)

#ordiplot(nmds,type="n")
#orditorp(nmds,display="species",col="red",air=0.01)
#orditorp(nmds,display="sites",cex=1.25,air=0.01)

ggplot() +
  geom_text(data=species.scores,aes(x=NMDS1,y=NMDS2,label=species),alpha=0.5) + 
  geom_point(data=image.scores,aes(x=NMDS1,y=NMDS2),size=3) + 
  geom_text(data=image.scores,aes(x=NMDS1,y=NMDS2,label=image),size=3,vjust=1) +  
  theme_bw() +
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        plot.background = element_blank())
  
#add groups + plot a hull around groups
#https://chrischizinski.github.io/rstats/vegan-ggplot2/

