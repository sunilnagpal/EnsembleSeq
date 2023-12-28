blastn -query FILENAME -db /path/BLASTDB/its/ITS_RefSeq_Fungi -outfmt "6 qseqid qlen length pident evalue sscinames sskingdoms staxids sblastnames scomnames" -max_target_seqs 1 -out BLASTFUN/FILENAME.blastout.txt -max_hsps 1
mkdir species
mkdir genus
for blasout in `ls *.blastout.txt`
do
name=`echo $blasout | cut -d "." -f1,2`
awk '{if($4 >= 90) print $0}' $blasout | cut -f6 | sort | uniq -c | awk '{print $2"_"$3"\t"$1}' > species/$name.count.txt
awk '{if($4 >= 90) print $0}' $blasout | cut -f6 | awk '{print $1}' | sort | uniq -c | awk '{print $2"\t"$1}' > genus/$name.count.txt
done
