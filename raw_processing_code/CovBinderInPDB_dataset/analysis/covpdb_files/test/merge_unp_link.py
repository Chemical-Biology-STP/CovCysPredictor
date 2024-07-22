#!/usr/bin/env python

import os,sys

# read the Uniprot info
fr = open(sys.argv[1])
header = fr.readline()
pdbunp = []
for line in fr.readlines():
   items = line.split(",")
   pdbidc  = items[0].strip()
   unpid   = items[1].strip()
   unpname = items[2].strip()
   pdbunp.append((pdbidc,unpid,unpname))

fr.close()
print("PDB ID/chain entries:",len(pdbunp))

# read the LINK info
fr = open(sys.argv[2])
pdblink = {}
pdbcyslnk = []  # this is for (PDB ID/chain, CYSxxx) only
for line in fr.readlines():
   items = line.split(",")
   pdbidc = "%s.%s" % (items[1].strip(),items[2].strip())
   print(pdbidc)
   cysnum = items[3].strip()
   lnk1 = items[4].upper().strip()
   lnk2 = items[5].upper().strip()
   # the ligand atom should: start with C (but not CU) -or- start with S
   # anything else should be classified as 'other': startswith(ZN,MG,MN,NI,FE,CU,K,...)
   if lnk1 != "CYS":
      sys.stdout.write("Warning: %s has non-CYS on the left?\n" % pdbidc)
   cyslnk = "%s%s" % (lnk1,cysnum)
   if (lnk2.startswith("C") and not lnk2.startswith("CU")) or lnk2.startswith("S"):
      lnk2_type = "C_or_S"
   else:
      lnk2_type = "other"
   # report the following info: PDB ID/chain,CYSxxx,link2 atom,link2 type
   # there should only be one covalent bond to a Cysteine in a given chain
   if (pdbidc,cyslnk) not in pdbcyslnk:
      pdbcyslnk.append((pdbidc,cyslnk))
      pdblink.setdefault(pdbidc,[]).append((cyslnk,lnk2,lnk2_type))

fr.close()
#print(pdblink)

print("PDB ID/chain entries in de-duplicated LINK file:",len(pdblink))

# Merge Uniprot info (pdbunp) with LINK info (pdblink)
fw = open(sys.argv[3],"w")
fw.write("PDBID.chain,Uniprot ID, Uniprot Name,CYS link,ligand link,ligand type\n")
for items in pdbunp:
   pdbidc = items[0]
   unpid  = items[1]
   unpname= items[2]
   #sys.stdout.write(pdbidc)
   if pdbidc in pdblink:
      for cyslnk,lnk2,lnk2_type in pdblink[pdbidc]:
         fw.write("%s,%s,%s,%s,%s,%s\n" % (pdbidc,unpid,unpname,cyslnk,lnk2,lnk2_type))
   else:
      # Some chains (i.e. proteins) in a PDB file don't contain covalently modified CYS.
      # Those chains are currently not written out, but maybe they should be?
      sys.stdout.write("Warning: %s not present in LINK data\n" % pdbidc)
      pass

fw.close()








