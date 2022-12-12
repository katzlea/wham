library(bnlearn)
library(Rgraphviz)
library(boot)
library(dplyr)

campaign="B121"

#---- LOAD DATA
load(paste0("wham_data/",campaign,"/",campaign,"_bni.RData"))
mydata<-as.data.frame(mydata)

#---------------------WITHOUT BOOTSRAP
## BAYESIAN ALGORITHM
bn_pc<-pc.stable(mydata)
## PLOT
graphviz.plot(bn_pc)

#---------------------WITH BOOTSTRAPPING
## RE-SAMPLING (BOOTSTRAP)
booty<-rsample::bootstraps(mydata,times = 100,apparent = TRUE)
booty<-as.list(booty$splits)
booties<-mydata
for (i in 1:length(booty)) {
  booties<-rbind(booties,booty[[i]][["data"]])
}
## BAYESIAN ALGORITHM
bn_pc_booty<-pc.stable(booties) #takes a while
## PLOT
graphviz.plot(bn_pc_booty)


#----------------------STUDYING THE NETWORK
compare(bn_pc,bn_pc_booty)







##################### BROUILLON
## NUMBER OF ARCS

table(bn_pc1[["arcs"]])
table(bn_pc[["arcs"]])

## STRENGTH OF ARCS

booty_s = boot.strength(mydata[4:ncol(mydata)],R=100, algorithm = "pc.stable") #using boot.strength!
hist(booty_s$strength)
# making a new df with sum of strengths
booty_s2<-inner_join(booty_s,booty_s,by=c("from"="to","to"="from"),keep=TRUE)
booty_s2<- booty_s2 %>% mutate(strength=strength.x+strength.y)
# adding the direction to df
direction <- 0
for (i in 1:nrow(booty_s2)) {
  n <- if (booty_s2$direction.x[i] == 0 && booty_s2$direction.y[i] ==0) NA
  else if (booty_s2$direction.x[i] > 0.6) "+1" else if (booty_s2$direction.x[i] < 0.4) "-1"
  else if (booty_s2$direction.x[i] <= 0.6 && booty_s2$direction.x[i] >= 0.4) "0"
  direction[i] <- n
  }
booty_s2$direction <- direction
# clean up df
bye<-c("strength.x","direction.x","from.y","to.y","strength.y","direction.y")
mydata<-mydata[ , !(names(mydata) %in% bye)]
str_df <- booty_s2[,!(names(booty_s2) %in% bye)]
str_df <- str_df %>% rename (node1 = from.x,node2 = to.x) %>%
  na.omit()
# study distribution
hist(str_df$strength,breaks=20) #distribution of strength
top<-str_df[(str_df$strength > 1), ] 
hist(top$strength,breaks=20) #distribution of strength (>1)



booty_s1 = boot.strength(booties,R=100, algorithm = "pc.stable") #using boot.strength!strength.plot(bn_pc,booty_s)


compare(bn_pc1,bn_pc)
