#!/bin/bash

# UGE parameters
#$ -N moe_ens-prop
#$ -cwd
#$ -l h_rt=2419200
#$ -j y
#$ -V
#$ -q default.q

# purge all modules from .bashrc and profiles
module purge

# load necessary modules
#module load MOE
module load MOE/2022.02_site


# run moebatch command
#moebatch -mpu 4 -run ./$1 -o output.mdb -exit
sh ./run_ensprop.sh

echo Finished at: $(date)
