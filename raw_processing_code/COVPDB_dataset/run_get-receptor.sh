#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_get-receptor.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
module load MOE/2022.02_site


#for file in *; do
#    if [ -d "$file" ]; then
#        echo "$file"; echo "Entering $file to run res_stats"; sleep 5; echo " "; moebatch -cd $file -exec "protein_proc [input:'$file.pdb', quickprep:0, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file:'${file}_receptor.pdb', use_receptor_only:1, quickprep_receptor_only:0, residue_stats: 0, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 5; (cd $file; pwd; ls; echo " "; sleep 5; mkdir receptor; mv ${file}_receptor.pdb receptor/; ls receptor/; echo " "; sleep 5; cd ../; echo " "; echo "Finished receptor_run for $file at: $(date)";echo " "; echo " "); sleep 10
#    fi
#done
#
#echo " "
#sleep 10

for file in *; do
    if [ -d "$file" ]; then
        echo "$file"; echo "Entering $file to run receptor_qkprep"; sleep 5; echo " "; moebatch -cd $file -exec "protein_proc [input:'$file.pdb', quickprep:0, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file:'${file}_receptor_qkprep.pdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 0, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 5; (cd $file; pwd; ls; echo " "; sleep 5; mv ${file}_receptor_qkprep.pdb receptor/; ls receptor/; echo " "; sleep 5; cd ../; echo " ";  echo "Finished receptor_qkprep_run for $file at: $(date)";echo " "; echo " "); sleep 10
    fi
done
