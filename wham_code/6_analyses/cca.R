library(vegan)

campaign="Example_campaign"

# ------------------------------------------------------------------------
#load(paste0("wham_data/",campaign,"/",campaign,"_abundance.RData"))
load(paste0("wham_data/",campaign,"/",campaign,"_summary.RData"))
# ------------------------------------------------------------------------

##########################################################################
# --- CANONICAL CORRESPONDANCE ANALYSIS ---
##########################################################################

# format
mydata<-data.frame(mydata,row.names=1)

# load metadata
load(paste0("wham_data/",campaign,"/",campaign,"_metadata.RData")) #has to be created somewhere...

# apply log+1 (remove errors due to rare species)
datalog<-decostand(mydata,"log")

# CCA
cca<-cca(mydata~.,env)
finalmodel<-ordistep(cca,scope=formula(cca))
vif.cca(finalmodel) #doesn't work (ncol needs a larger value...)

# test significance of cca
anova.cca(finalmodel)
anova.cca(finalmodel, by="terms") #significance of the env variables
anova.cca(finalmodel, by="axis") #significance of the CCA axes #doesn't work (ncol needs a larger value...)

#plot
plot(finalmodel, 
     xlim = c(-2,2),
     ylim = c(-2,2),
     display = c("sp","cn","wa"))

#more info https://rfunctions.blogspot.com/2016/11/canonical-correspondence-analysis-cca.html
