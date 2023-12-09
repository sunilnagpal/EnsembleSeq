#Code title: Raredynamics
#Purpose: Dynamic monitoring of species saturation in each barcode specific data of oxford nanopore
#Author: Sunil Nagpal
#version: 1.0
#Dependecies: dynamic_hier_counts.py, rdp, raredynamic_curves.r

#directory to store time window specific fastas
mkdir temporals 

#directory to track already existing analyses on previous time windows
mkdir cache 

#time window count tracker for clean charting downstream
counter=0

#file to track already existing analyses on previous time windows
cachecheck="cache/processed.log"

####uncomment the following block if basecaller is writing in gzup format#####
#mkdir copyofdata
#cp *.gz copyofdata
#cd copyofdata
#gunzip *
#mv *.fastq ../
#cd ..
#rm -rf copyofdata

#if the data has already been copied out of the location where real time data is being written, you may skip creating a backup (i.e. copyofdata folder) and directly gunzip in the same directory
#############################################################################

#list temporally written fastq files by fast basecaller during the ongoing run of sequencing. If the output is gzipped ensure to uncomment the following
for realreads in `ls -ctr1 *.fastq | head -2`
  do
    if [ -f "$cachecheck" ] && grep -q "T$counter.fasta" $cachecheck; then
        echo "T$counter already available in cache. Skipping to next window of sequences"
    else
              #if this is the first time window, there is no need to aggregate with previous window
              if [ $counter == 0 ]
                then
		   #convert fastq to fasta. This is fast method without primer trimming or read length filters. Those can be added but not necessay given we are aiming for approximate estimation of saturation
                   sed -n '1~4s/^@/>/p;2~4p' $realreads > temporals/T$counter.fasta
		   
		   #use rdp to classify till genus level. Emu, though provides species level assignments is slow and is also not suitable for diversity analyses given the expectation maximization algorithm. Add --gene fungalits_unite parameter to the following command to perform the same task for mycobiome
                   java -Xmx1g -jar rdp/dist/classifier.jar classify -c 0.8 -f fixrank -o T$counter.classified -h T$counter.hier temporals/T$counter.fasta

     	           #temporary file needed to create a clean header for genera counts from hier files
     		   echo "" > temporaryfile
		   awk -v count=$counter '{print "genera\tT"count}' temporaryfile > T$counter.tsv

		   #extract genera counts from the hier files generated using RDP for the time window being processed in this loop
                   grep "genus\s" T$counter.hier | rev | cut -f1,3 | rev >> T$counter.tsv

     	           #update the log
                   echo "T$counter.fasta" >> cache/processed.log
              else 
	          #given this is not the first time window, there is a need to aggregate with previous window
                  previous=`expr $counter - 1`
                  sed -n '1~4s/^@/>/p;2~4p' $realreads > temporals/T$counter.fasta
                  java -Xmx1g -jar rdp/dist/classifier.jar classify -c 0.8 -f fixrank -o T$counter.classified -h T$counter.hier temporals/T$counter.fasta
		  echo "" > temporaryfile
                  awk -v count=$counter '{print "genera\tT"count}' temporaryfile > T$counter.tsv
                  grep "genus\s" T$counter.hier | rev | cut -f1,3 | rev >> T$counter.tsv

                  #using the dynamic_hier_counts.py code to aggregate taxonomic composition aggregated till previous window with that observed in the current window. The last argument ensures that the aggregated composition is stored in latest window, allowing recursive aggregation with next windows.
                  python dynamic_hier_counts.py T$previous.tsv T$counter.tsv T$counter.tsv
                  echo "T$counter.fasta" >> cache/processed.log
              fi
    fi
    
    counter=`expr $counter + 1`
done

#once all windows are updated, perform rarefaction analysis and visualize the temporal trend of saturation for the given barcode
Rscript raredynamic_curves.r T$counter.tsv
rm temporaryfile
