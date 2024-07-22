#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_prop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
module load MOE/2022.02


for file in *; do
    if [ -d "$file" ]; then
        echo "$file"; echo "Entering $file to generate stats for cutoff_10"; sleep 5; cd $file; cd rosetta; pwd; ls; echo " "; echo "entering cutoff_10"; cd cutoff_10; pwd; echo " "; mkdir no_qkprep ; cp *.pdb no_qkprep/; cd no_qkprep/; pwd; ls; echo " "; sleep 10; sed -i '1 s/^/#/' *.pdb; head -1 *.pdb; sleep 5; echo " "; echo "running MOE_res-stats:" ; moebatch -exec "protein_proc [input: '.', quickprep:0, input_format: 'pdb', split_system: 0, output_format: 'mdb', output_file: '${file}_cutoff_10.mdb', use_receptor_only:0, quickprep_receptor_only:0, residue_stats: 1, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 5; pwd; ls; echo " "; mkdir res_stat_results; mv report* res_stat_results/; ls */; cd ../../../../; echo " "; echo "Finished residue_stats for $file for cutoff_10 at: $(date)"; echo " "; echo " "; sleep 10
    fi
done


