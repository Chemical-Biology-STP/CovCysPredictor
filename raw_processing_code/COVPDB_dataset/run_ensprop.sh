#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020
#source /home/awooner1/load_moe.sh
#module load MOE/2022.02_site



for file in *; do
    if [ -d "$file" ]; then
        echo "$file";echo "Entering $file to run residue ens_prop";sleep 10; echo " "; (cd $file; pwd; ls; echo " "; mkdir ens_propsamp; ls ; echo " "; cp structures.mdb ens_propsamp; cp /home/awooner1/bin/run_enspKa.sh ens_propsamp; echo "Entering ens_propsamp folder of $file to run property calculations:"; cd ens_propsamp; echo " "; ls ; sleep 5;moebatch -run ./run_enspKa.sh -mpu 6; sleep 15; echo "Finished Ensprop-sampling for $file at: $(date)";echo " "; echo " ");sleep 10
    fi
done

