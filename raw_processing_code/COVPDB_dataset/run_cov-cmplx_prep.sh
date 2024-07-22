#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_prop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
source /home/awooner1/load_moe.sh


for file in *; do
    if [ -d "$file" ]; then
        echo "$file";echo "Entering $file to qkprep_cov-cmplx";sleep 10; echo " ";moebatch -cd $file -exec "protein_proc [input: '$file.pdb', quickprep:1, input_format: 'pdb', split_system: 0, output_format: 'mdb', output_file: '${file}_cmplx.mdb', use_receptor_only:0, quickprep_receptor_only:0, residue_stats: 0, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit; sleep 10; moebatch -cd $file -exec "protein_proc [input: '$file.pdb', quickprep:1, input_format: 'pdb', split_system: 0, output_format:'pdb', output_file: '${file}_cmplx.pdb', use_receptor_only:0, quickprep_receptor_only:0, residue_stats: 0, report_file: 'report.txt', serialize_by: 'chain tag'];" -exit ;(cd $file; pwd; ls; echo " "; mkdir qkprep_cmplx; mv ${file}_cmplx.* qkprep_cmplx/; echo "Finished qkprep_cov-cmplx for $file at: $(date)";echo " "; echo " ");sleep 10
    fi
done

