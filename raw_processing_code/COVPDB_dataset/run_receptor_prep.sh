#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_prop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
source /home/awooner1/load_moe.sh
source /home/awooner1/load_pKAI.sh


for file in *; do
    if [ -d "$file" ]; then
        echo "$file";echo "Entering $file to run qkprep on receptor";sleep 10; echo " ";moebatch -cd $file -exec "protein_proc [input:'$file.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file: '${file}_receptor_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 0, report_file: 'report.txt',serialize_by: 'chain tag'];" -exit; sleep 10; (cd $file; pwd; ls; echo " "; mkdir qkprep_receptor; mv ${file}_receptor_prep.pdb ./qkprep_receptor; echo "Entering qkprep_receptor directory for ${file}..."; cd qkprep_receptor; pwd; ls; echo " "; sleep 10; echo "Generating pKAI report for ${file}_receptor_prep.pdb..."; pKAI --model pKAI+ ${file}_receptor_prep.pdb > ${file}_pKAI-report.txt; sleep 5; grep CYS ${file}_pKAI-report.txt > ${file}_CYSpKAI.txt; ls ; sleep 5; echo " "; echo "Finished pKAI run..."; echo " "; echo "Finished process for $file at: $(date)";echo " "; echo " "; echo " ");sleep 10
    fi
done

