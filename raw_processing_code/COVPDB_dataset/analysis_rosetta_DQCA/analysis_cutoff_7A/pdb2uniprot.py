#!/usr/bin/env python

import os,sys
import csv
import psycopg2

fin = open(sys.argv[1])
reader = csv.reader(fin, delimiter=',')
# header = next(reader)  # reading list of PDB IDs, no header
pdb_ids = []
for i,row in enumerate(reader):
   pdb_id = row[0]
   if pdb_id in pdb_ids:
      sys.stderr.write("duplicate PDB entry for %s ...skipping\n" % pdb_id)
      continue
   else:
      pdb_ids.append(pdb_id)
fin.close()

con = psycopg2.connect('dbname=hithub host=fangorn.nibr.novartis.net')
cur = con.cursor()

sql = """
select distinct p.pdb_id,p.chain_id,p.accn,u.entry_name
from pdb.chain2unp p
join uniprot.uniprotkb u on u.accn = p.accn
where p.pdb_id = %s
"""


pdb2info = []
for pdb_id in pdb_ids:
   sys.stdout.write("%s\n" % pdb_id)
   # for each input PDB ID, return (by chain) uniprot_name(s) & chain(s), etc.
   cur.execute(sql, (pdb_id,))
   if cur.rowcount == 0:
      pass
   else:
      pdbinfo = cur.fetchall()
      for pdb_id,pdb_chain,unp_id,unp_name in pdbinfo:
         row = ["%s.%s" % (pdb_id,pdb_chain),unp_id,unp_name]
         pdb2info.append(row)

cur.close()
con.close()

fw = open(sys.argv[2], "w")
writer = csv.writer(fw, lineterminator=os.linesep)
writer.writerow(["PDB ID/chain","Uniprot ID","Uniprot Name"])
for row in pdb2info:
   writer.writerow(row)
fw.close()

