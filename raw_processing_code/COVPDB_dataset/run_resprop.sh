#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_prop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
source /home/awooner1/load_moe.sh


for file in *; do
    if [ -d "$file" ]; then
        echo "$file";echo "Entering $file to run residue_stats";sleep 10; echo " ";moebatch -cd $file -exec "protein_proc [input: cd [], quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'mdb', output_file: 'structures.mdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 1, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10;(cd $file; pwd; ls; echo " "; mkdir res_stat_results; mv report* res_stat_results/; echo "Finished residue_stats for $file at: $(date)";echo " "; echo " ");sleep 10
    fi
done

