#Code title: Raredynamic curves
#Purpose: Rarefaction analysis of each time window in the input dataframe and creating incremental rarefaction curves in time window specific facets. This file must remain in the same directory as raredynamics.sh
#Author: Sunil Nagpal
#version: 1.0

library("ggplot2")
library("iNEXT")
args <- commandArgs(trailingOnly = TRUE)

df=read.table(args[1],sep="\t",row.names=1,header=TRUE) #args[1] will pertain to dymanically aggregated taxa table

#count number of windows
timepoints=ncol(df)

#create a list for neat titles of facets (e.g. T0, T1, T2...)
levelorder <- list()
for (i in 0:timepoints) {
  levelorder[[i + 1]] <- paste0("T", i)
}

#calculate the factor for deciding number of columns of facets, given the detected number of time points
factr=timepoints/8

#if less time windows are detected, draw facets in a single column
if(factr<0.5)
{
factr=1
}

#rarefaction analysis
out=iNEXT(as.matrix((df)),nboot=0,q=c(0,1,2))

#draw curves modifying the ggiNEXT outputs through ordered faceting in ggplot2
p <- ggiNEXT(out, facet.var="Assemblage") + facet_wrap(~factor(Assemblage,levels=levelorder),ncol=as.integer(factr))

#save as needed
ggsave("Raredynamics.pdf",width=15,height=20)
