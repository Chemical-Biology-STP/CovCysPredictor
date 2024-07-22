#!/usr/bin/env python

import os,sys,glob


# all MOE report files are in Ernest's directory:
# /mnt/tmplabdata/caddusers/awooner1/COVPDB_prj/cys_dataset (res_stat_results subdirectory)

#print(len(report_files))

report_files = ["report_1ATK.txt",]  #"report_1WOF.txt"]
report_files = ["report_1F42.txt",]
report_files = glob.glob("/mnt/tmplabdata/caddusers/awooner1/COVPDB_prj/cys_dataset_rerun/*/NQ_fullsys/res_stat_results/*.txt")

fw = open(sys.argv[1],"w")
header = ["PDBID.chain","Res","Pos","Type","%Exposure","S.A.","pKa","Charge","NearRes"]
fw.write("%s\n" % ",".join(header))
for i,fname in enumerate(report_files):
   fr = open(fname)
   print(i,fname)
   # skip first 6 lines
   for i in range(7):
      fr.readline()
   # parse the residue properties
   for i,line in enumerate(fr.readlines()):
      items = [x.strip() for x in line.split("\t")]
      pdbid,chain = items[0].split(".")
      pdbidc = pdbid.lower()+"."+chain
      pos = items[1]
      res = items[2]
      uid = items[3]
      rtyp= items[4]
      pexp= items[5]
      sa  = items[6]
      pka = items[7]
      chg = items[8]
      nres= items[9].split()
      #print(pdbidc,sa,pka,chg,nres)
      if res == "CYS" and pka != "":
         fw.write("%s,%s%s,%s,%s,%s,%s,%s,%s,%s\n" % (pdbidc,res,uid,pos,
                   rtyp,pexp,sa,pka,chg,"|".join(nres)))
fw.close()

