#!/bin/bash
source source4rosetta_3.13.sh

for longf in ./resfiles/2lp8*; 
do
  f=${longf##*/}
  pdbid=${f:0:4}
  chain=${f:5:1}
  cutoff=${f:7:1}
  if [ $cutoff = "1" ]; then
    cutoff="10"
  fi
  preppedchain=${pdbid}/prot_pdb_chains/${pdbid}_${chain}_prep.pdb
  #echo $f
  #echo $pdbid
  #echo $chain
  #echo $cutoff
  #echo $preppedchain
  fixbb.static.linuxgccrelease -s ${preppedchain} -resfile ./resfiles/$f -nstruct 1 -ex1 -ex2 -score:weights soft_rep_design -use_input_sc -ignore_unrecognized_res -multi_cool_annealer 10 -mute basic core
  mv ${pdbid}_${chain}_prep_0001.pdb ./${pdbid}/rosetta/cutoff_${cutoff}/${pdbid}_${chain}_prep_0001.pdb
  #mv ${pdbid}_${chain}_prep_0001.pdb /home/reinsbr1/cys_andrei/${pdbid}_${chain}_${cutoff}_prep_0001.pdb 
done

