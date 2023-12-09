#Code title: Raredynamics
#Purpose: Dynamic monitoring of species saturation in each barcode specific data of oxford nanopore
#Author: Sunil Nagpal
#version: 1.0
mkdir temporals
mkdir cache
counter=0
cachecheck="cache/processed.log"
for realreads in `ls -ctr1 *.fastq | head -2`
  do
    if [ -f "$cachecheck" ] && grep -q "T$counter.fasta" $cachecheck; then
        echo "T$counter already available in cache. Skipping to next window of sequences"
    else
              if [ $counter == 0 ]
                then
                   sed -n '1~4s/^@/>/p;2~4p' $realreads > temporals/T$counter.fasta
                   java -Xmx1g -jar dist/classifier.jar classify -c 0.8 -f fixrank -o T$counter.classified -h T$counter.hier temporals/T$counter.fasta
		   echo "" > temporaryfile
                   awk -v count=$counter '{print "genera\tT"count}' temporaryfile > T$counter.tsv
                   grep "genus\s" T$counter.hier | rev | cut -f1,3 | rev >> T$counter.tsv
                   echo "T$counter.fasta" >> cache/processed.log
              else 
                  previous=`expr $counter - 1`
                  sed -n '1~4s/^@/>/p;2~4p' $realreads > temporals/T$counter.fasta
                  java -Xmx1g -jar dist/classifier.jar classify -c 0.8 -f fixrank -o T$counter.classified -h T$counter.hier temporals/T$counter.fasta
		  echo "" > temporaryfile
                  awk -v count=$counter '{print "genera\tT"count}' temporaryfile > T$counter.tsv
                  grep "genus\s" T$counter.hier | rev | cut -f1,3 | rev >> T$counter.tsv
                  python dynamic_hier_counts.py T$previous.tsv T$counter.tsv T$counter.tsv
                  echo "T$counter.fasta" >> cache/processed.log
              fi
    fi
    
    counter=`expr $counter + 1`
done
Rscript raredynamic_curves.r T$counter.tsv
rm temporaryfile
