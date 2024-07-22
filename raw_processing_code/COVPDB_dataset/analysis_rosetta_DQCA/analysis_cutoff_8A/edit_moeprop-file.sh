#!/bin/bash
cp pdbs_cys_moeprops.csv pdbs_cys_moeprops_copy.csv
ls pdbs_cys_moeprops*
echo " "
sed 's/_[a-z]_8_prep_0001//g' pdbs_cys_moeprops.csv > 1.csv
sleep 5
sed 's/_[a-z]_prep_0001//g' 1.csv > 2.csv
sleep 5
ls ./*.csv
echo " "
mv 2.csv pdbs_cys_moeprops.csv
echo " "
rm 1.csv
wc -l pdbs_cys_moeprops.csv
wc -l pdbs_cys_moeprops_copy.csv

echo "Finished at:" $(date)
