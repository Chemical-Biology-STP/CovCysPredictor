#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_prop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
module load MOE/2022.02


for file in *; do
    if [ -d "$file" ]; then
        echo "$file"; echo "Entering $file to run rosetta_prep"; sleep 5; cd $file; mkdir rosetta; cd rosetta; mkdir cutoff_none cutoff_7 cutoff_8 cutoff_9 cutoff_10; cp ../prot_pdb_chains/*.pdb cutoff_none; pwd; ls; echo " "; echo "entering cutoff_none"; cd cutoff_none; pwd; ls; sleep 5; echo " "; moebatch -exec "protein_proc [input: '.', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'mdb', output_file: 'all_structures.mdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 1, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10; echo " "; pwd; ls; echo " "; mkdir res_stat_results; mv report* res_stat_results/; ls */; cd ../../../; echo " "; echo "Finished residue_stats for $file at: $(date)"; echo " "; echo " "; sleep 10
    fi
done

