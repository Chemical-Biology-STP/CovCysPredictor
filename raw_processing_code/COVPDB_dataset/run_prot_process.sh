#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
source /home/awooner1/load_moe.sh


for file in *; do
    if [ -d "$file" ]; then
        echo "$file";echo "Entering $file to run prot_proc";sleep 5; echo " ";moebatch -cd $file -exec "proc_pdb_all_chains [input:'$file.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file:'${file}_*_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, residue_stats: 0, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10;(cd $file; pwd; ls; echo " "; mkdir prot_pdb_chains; mv ${file}_*_prep.pdb prot_pdb_chains/; echo "Finished prot_proc for $file at: $(date)";echo " "; echo " ");sleep 10
    fi
done

#for filename in *_prep.pdb; do mv "$filename" "4c5l_${filename}"; done

#moebatch -exec "protein_proc [input:'4c5l.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file: '4c5l_A_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, retain_cletter: ['A'],residue_stats: 0, serialize_by: 'chain tag'];" -exit
#
#moebatch -exec "protein_proc [input:'4c5l.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file: '4c5l_B_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, retain_cletter: ['B'], residue_stats: 0, serialize_by: 'chain tag'];" -exit
#
#moebatch -exec "protein_proc [input:'4c5l.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format:   'pdb', output_file: '4c5l_C_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, retain_cletter: ['C'], residue_stats: 0, serialize_by: 'chain tag'];" -exit
#
#moebatch -exec "protein_proc [input:'4c5l.pdb', quickprep:1, input_format: 'pdb', split_system: 1, output_format: 'pdb', output_file: '4c5l_D_prep.pdb', use_receptor_only:1, quickprep_receptor_only:1, retain_cletter: ['D'], residue_stats: 0, serialize_by: 'chain tag'];" -exit
#
#echo " "
#sleep 5
#mkdir receptor_qkprep
#mv *_prep.pdb receptor_qkprep
#ls receptor_qkprep
#echo " "
#sleep 10
#echo "Done recep_qkprep for pdb files at:"$(date)
