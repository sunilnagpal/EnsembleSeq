#NCBI doesn't support pod5 files hence converting those to fast5 format
for files in `ls *.pod5`
do
name=`echo $files | cut -d "." -f1`
  pod5 convert to_fast5 $files --file-read-count 1000000 --output $name.fast5 
done
