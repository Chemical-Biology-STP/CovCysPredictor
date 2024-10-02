# CHANGE PATH TO fpocket HERE
fpocket=~/fpocket/bin/fpocket

input_file=$1
output_dir=$2
input_stub=$(basename "$1" .pdb)
echo $input_file
echo $output_dir
echo $input_stub

cp ${input_file} ${output_dir}

if ! test -f ${output_dir}/cysteines_in_fpocket_${input_stub}.log; then
  $fpocket -f ${output_dir}/${input_stub}.pdb
  grep "CA CYS" ${output_dir}/${input_stub}_out/pockets/*pdb | awk '{print $5,$6}' | uniq > ${output_dir}/cysteines_in_fpocket_${input_stub}.log
fi

python3 ./predict_cys_covalency.py ${input_stub}.pdb ${output_dir}

# Only un-comment if you need rds files for downstream analysis
# pkl and txt files are provided as default output
# Rscript --vanilla ./convert_files.R ${output_dir}
