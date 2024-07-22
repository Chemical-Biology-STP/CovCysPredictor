#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_prop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
module load MOE/2022.02


for file in *; do
    if [ -d "$file" ]; then
        echo "$file"; echo "Entering $file to run rosetta_cutoff"; sleep 5; cd $file; cd rosetta; pwd; ls; echo " "; echo "entering cutoff_9"; cd cutoff_9; pwd; sed -i '1 s/^/#/' *.pdb; rm -rf structures.mdb res_stat_results; ls; echo " "; head -1 *.pdb; sleep 5; echo " "; echo "running MOE_res-prop now:" ; moebatch -exec "protein_proc [input: '.', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'mdb', output_file: 'structures.mdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 1, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10; echo " "; pwd; ls; echo " "; mkdir res_stat_results; mv report* res_stat_results/; ls */; cd ../../../; echo " "; echo "Finished residue_stats for $file for cutoff_9 at: $(date)"; echo " "; echo " "; sleep 10
    fi
done


