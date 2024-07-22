#!/bin/bash   ################################################################################################################################################################################   #####################################################
### Usage: sh ./run_db-export_resprop.sh ################################################################################################################################################################################  #####################################################

### Load MOE version.2020.0901
### Database export function only works in later versions of MOE (i.e., MOE2020.0901, MOE2020.02, or higher)
export PATH="$PATH:/home/awooner1/moe2020/bin"


for file in *; do
    if [ -d "$file" ]; then
        echo "$file";echo "Entering $file to export residue table for ens_propsamp";sleep 5; echo " "; (cd $file; pwd; ls; echo " "; sleep 5; echo "Entering ens_propsamp folder of $file to generate ensemble residue table:"; cd ens_propsamp; pwd; ls; echo " "; sleep 5; moebatch2020 -exec "db_export_res_properties [mdb:'structures.mdb', ascii_export:1]" -exit; sleep 5; echo " "; pwd; ls; echo " ";echo "Finished exporting ens_residue_report for $file at: $(date)";echo " "; echo " ");sleep 10
    fi
done

