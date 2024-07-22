#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
module load MOE/2022.02


for file in *; do
    if [ -d "$file" ]; then
        echo "$file"; echo "Entering $file to split protein_receptor"; sleep 5; echo " "; moebatch -cd $file -exec "proc_pdb_all_chains [input:'$file.pdb', quickprep:0, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file:'${file}_*_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 0, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10; (cd $file; pwd; ls; echo " "; sleep 5; mkdir SQCA; mv ${file}_*_prep.pdb SQCA/; cd SQCA; pwd; echo " "; sleep 5; moebatch -exec "protein_proc [input: '.', quickprep:1, input_format: 'pdb', split_system: 0, output_format:'mdb', output_file: 'split_receptors.mdb', use_receptor_only:0, quickprep_receptor_only:0, residue_stats: 1, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 5; pwd; ls; echo " "; sleep 5; mkdir res_stat_results; mv report* res_stat_results/; ls */; cd ../../; echo " "; echo "Finished SQCA_run for $file at: $(date)";echo " "; echo " "); sleep 10
    fi
done


