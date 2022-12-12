library(tidyverse)

campaign="Example_data"

# _________________________________________________________________
load(paste0("wham_data/",campaign,"/",campaign,"_abundance.RData"))
# _________________________________________________________________


# GROUP DATA BY DIVE (SUMMARISE)
mydata <- mydata %>% select(1,3:ncol(mydata)) %>% group_by(dive) %>% summarise(across(everything(),sum,na.rm=TRUE))
save(mydata,file=paste0("wham_data/",campaign,"/",campaign,"_summary.RData"))


# OTHER GROUPINGS... wip
taxa<-read.csv(paste0("wham_data/",campaign,"/",campaign,"_taxa.csv"))
#other file from BIIGLE Label tree?

