#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
module load MOE/2022.02_site


for file in *; do
    if [ -d "$file" ]; then
        echo "$file"; echo "Entering $file to run res_stats"; sleep 10; echo " "; moebatch -cd $file -exec "protein_proc [input:'$file.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'mdb', output_file:'${file}_sys_DQCT.mdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 1, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10; (cd $file; pwd; ls; echo " "; sleep 10; mkdir DQCT; mv ${file}_sys_DQCT.mdb report*.txt DQCT/; cd DQCT; pwd; echo " "; sleep 10; ls; echo " "; sleep 10; mkdir res_stat_results; mv report* res_stat_results/; ls */; cd ../../; echo " "; echo "Finished DQCT_run for $file at: $(date)";echo " "; echo " "); sleep 20
    fi
done

