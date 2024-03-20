#Assuming there are barcode specific directories where individual pod5 files were written, following script will merge the pod5 files for ease of submission to the sequence archives
for files in `ls -d barcode* -1`
do 
  cd $files
  pod5 merge *.pod5 -o ../$files.pod5
  cd ..
done
