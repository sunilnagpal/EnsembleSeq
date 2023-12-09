#Code title: Dynamic Hier Counts
#Purpose: Dynamic aggregation of the taxonomic composition for incremental time windows to enable monitoring of species saturation by raredynamics.sh. This file must be present in the same directory as raredynamics.sh
#Author: Sunil Nagpal
#version: 1.0

import pandas as pd
import sys

#read previous time window composition (only the aggregated last window)
tprevious=pd.read_csv(sys.argv[1],sep="\t",header=0,index_col=False)
tprlast=tprevious[['genera',tprevious.columns[-1]]]

#read current time window composition
tnow=pd.read_csv(sys.argv[2],sep="\t",header=0,index_col=False)

#merge two time window to create a union
dfaggregate=pd.merge(tprlast,tnow,on='genera',how="outer")

#aggregare the compositions of two time windows to create latest aggregated composition
dfaggregate['counts']=dfaggregate.drop('genera',axis=1).sum(axis=1)
dfaggregate=dfaggregate[['genera','counts']]
dfaggregate.columns=['genera',sys.argv[2].split(".")[0]]

#merge with previous dataframe of incremental time window based aggregated compositions
dynamichiers=pd.merge(tprevious,dfaggregate,on='genera',how="outer")

#save the dataframe
dynamichiers.fillna(0).to_csv(sys.argv[3],sep="\t",index=None)
