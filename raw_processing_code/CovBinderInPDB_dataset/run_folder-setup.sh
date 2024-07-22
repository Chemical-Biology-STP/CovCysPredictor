#!/bin/bash

#Remove first three characters in filename
for file in *.ent; do
    mv "$file" `echo $file | cut -c 4-`
done
sleep 10

#Rename *.ent to *.pdb filenames
for file in *.ent; do
    mv "$file" "${file%.ent}.pdb"
done
sleep 10

ls
echo " "
echo "completed file renaming"
sleep 10

#Make folders and move pdb files to folders
for file in ./*.pdb; do
    mkdir "${file%.pdb}" && mv "$file" "${file%.pdb}"
done
sleep 10

ls
echo " "
sleep 20

#Done
echo " "
echo " "
echo "Finished at:" $(date)
