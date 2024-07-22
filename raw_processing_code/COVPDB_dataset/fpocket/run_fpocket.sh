module load fpocket
for i in ../*/*receptor/*_receptor*pdb;
do
  fpocket -f "$i";
done 
