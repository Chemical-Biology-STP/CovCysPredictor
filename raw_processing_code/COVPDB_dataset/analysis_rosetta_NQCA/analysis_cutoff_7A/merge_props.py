#!/usr/bin/env python

import os,sys

# read PDBID/chain, Uniprot info and LINK info
fr = open(sys.argv[2])
header = fr.readline()
unplink = {}
for line in fr.readlines():
   items = line.strip().split(",")
   pdbidc = items[0]
   unpid  = items[1]
   unpname= items[2]
   covcys = items[3]
   covlig = items[4]
   ligtyp = items[5]
   unplink.setdefault(pdbidc,[]).append((unpid,unpname,covcys,covlig,ligtyp))

fr.close()

# scan the dictionary
"""
for pdbidc in unplink:
   if len(unplink[pdbidc]) > 1:
      print(unplink[pdbidc])
"""

# read MOE properties for all PDB files
fr = open(sys.argv[1])
header = fr.readline().strip()
# write a new header
sys.stdout.write("%s,Uniprot ID,Uniprot Name,CYS link,ligand link,ligand type\n" % header)
for line in fr.readlines():    # MOE properties
   items = line.strip().split(",")
   pdbidc = items[0]
   res    = items[1]
   if pdbidc in unplink: # i.e. there is a covalent CYS in the chain
      for unpid,unpname,covcys,covlig,ligtyp in unplink[pdbidc]:  # Uniprot & LINK info
         #print([unpid,unpname,covcys,covlig,ligtyp])
         if res == covcys:
            newline = items + [unpid,unpname,covcys,covlig,ligtyp]
            break
      else:
         covcys = ""
         covlig = "NA"
         ligtyp = "free"
         newline = items + [unpid,unpname,covcys,covlig,ligtyp]
      #print(newline)
      sys.stdout.write("%s\n" % ",".join(newline))



