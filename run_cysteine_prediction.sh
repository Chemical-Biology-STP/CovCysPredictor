# Bryn Marie Reimer
# 2024
# Run this bash script to both pre-process
# your PDB files with fpocket as well as run
# a prediction of the ligandability of a cysteine residue

# If your fpocket installation is held somewhere different,
# please update that here
fpocket=/mnt/DATA2/miniforge3/envs/CovCysPredictor/bin/fpocket

# Usage:
# ./run_cysteine_prediction.sh my_pdb_file.pdb output_dir/
input_file=$1
output_dir=$2
input_stub=$(basename "$1" .pdb)
echo $input_file
echo $output_dir
echo $input_stub

# copy pdb file to output directory
cp ${input_file} ${output_dir}

# run and parse fpocket output
if ! test -f ${output_dir}/cysteines_in_fpocket_${input_stub}.log; then
  $fpocket -f ${output_dir}/${input_stub}.pdb
  grep "CA CYS" ${output_dir}/${input_stub}_out/pockets/*pdb | awk '{print $5,$6}' | uniq > ${output_dir}/cysteines_in_fpocket_${input_stub}.log
fi

# prediction with the python script
python3 CovCysPredictor.py ${input_stub}.pdb ${output_dir}

