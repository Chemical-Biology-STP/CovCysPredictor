module purge
module load R
module load fpocket
module load PythonDS


input_file=$1
output_dir=$2
input_stub=$(basename "$1" .pdb)
echo $input_file
echo $output_dir
echo $input_stub

cp ${input_file} ${output_dir}

if ! test -f ${output_dir}/cysteines_in_fpocket_${input_stub}.log; then
  fpocket -f ${output_dir}/${input_stub}.pdb
  grep "SG CYS" ${output_dir}/${input_stub}_out/pockets/*pdb | awk '{print $6}' | uniq > ${output_dir}/cysteines_in_fpocket_${input_stub}.log
fi

python /da/CADD/covcyspredictor/predict_cys_covalency_Feb24.py ${input_stub}.pdb ${output_dir}

Rscript --vanilla /da/CADD/covcyspredictor/convert_files.R ${output_dir}
