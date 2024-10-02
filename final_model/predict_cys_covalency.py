# move from pymol to biopython
from Bio.PDB import PDBParser
from Bio.PDB.SASA import ShrakeRupley
import math
import sys
import pickle
import json

### INPUT

if len(sys.argv) < 3:
    print("Must input exactly one PDB file name and one output directory")
    print("e.g. `python ./predict_cys_covalency.py my_file.pdb output_dir/`")
    sys.exit()
pdb_file = sys.argv[1]
output_dir = sys.argv[2] 

print("Running prediction... note that solvents, ligands, cofactors, and ions are removed automatically")

### CONSTANTS and DATA

# regression constants
# calculated from median-performing model
# predicting y ~ intercept + log_exp + any_fpocket + aa
# NQNC model from CB
with open('./analysis_code/coefficients.json', 'r') as file:
    model_coefs = json.load(file)[0]

beta_0 = model_coefs["intercept"]
beta_log_exp = model_coefs["log_exp"]
beta_any_fpocket = model_coefs["any_fpocket"]
beta_aa_dict = {
    key: val for key, val in model_coefs.items()
     if key not in ["intercept", "log_exp", "any_fpocket", "cutoff"]
}
cutoff = model_coefs["cutoff"]

### CALCULATED PROPERTIES

# calculate solvent-accessible surface area
# and amino acid neighborhood

parser = PDBParser()
# condition on whether the pdb file is extant in the output directory
structure = parser.get_structure("protein", f"{pdb_file}")

# minimally clean file
cmd.remove("solvent")
cmd.remove("polymer.nucleic")
cmd.remove("inorganic")
cmd.remove("organic")

# get first chain
chains = cmd.get_chains()
if len(chains) >= 2: 
    for i in range(1, len(chains)):
        cmd.remove('chain %s' % chains[i])
        print(f"Removing chain {chains[i]}...") 

stored.residues = []
cmd.iterate('resname cys and name ca', 'stored.residues.append(resi)')

sasa_per_residue = {}
neighborhood = {}
for i in stored.residues:
    sasa_per_residue[i] = cmd.get_area('resi %s' % i )
    
    stored.neigh_i = []
    cmd.iterate('(resi %s) around 4.5' % i, 'stored.neigh_i.append(resi)')
    
    stored.neigh = []
    for j in set(stored.neigh_i):
        cmd.iterate('resi %s and name ca' % j, 'stored.neigh.append(oneletter)')
    
    neighborhood[i] = list(stored.neigh)
    

# Calculate SASA
sasa_calculator = ShrakeRupley()
sasa_calculator.compute(structure)

# Access SASA values
for residue in structure[0].get_residues():
    print(residue, residue.sasa)

### FPOCKET HELPER
with open(f"./{output_dir}/cysteines_in_fpocket_{pdb_file[:-4]}.log") as fi:
    tmp_cys_in_fpocket = fi.readlines()

cys_in_fpocket = [l.strip('\n') for l in tmp_cys_in_fpocket]

results_dict = {x: {"log_exp": [], "pocket": [], "aa_env": [], 
                    "score": 0.0, "predicted_modifiable": False} for x in stored.residues}

### PREDICTION ENGINE
for k in stored.residues:
    # calculate log solvent exposure and fpocket inclusion per cysteine residue
    log_exp = math.log(sasa_per_residue[k] + 1)
    any_fpocket = int(k in cys_in_fpocket)
    # apply beta coefficients to calculated properties
    nu = beta_0 + beta_log_exp*log_exp + beta_any_fpocket*any_fpocket + sum(neighborhood[k].count(aa)*beta_aa_dict[aa] 
                                                                            for aa in list(set(neighborhood[k])) 
                                                                           if aa in beta_aa_dict.keys())
    results_dict[k]["log_exp"] = log_exp
    results_dict[k]["pocket"] = any_fpocket
    results_dict[k]["aa_env"] = neighborhood[k]
    # logistic link function
    mu = math.exp(nu)/(1 + math.exp(nu))
    #print(f"Cysteine {k}: score = {mu:.2}.")
    results_dict[k]["score"] = f"{mu:.2}"
    if mu >= cutoff:
        results_dict[k]["predicted_modifiable"] = True
        #print("--> LIKELY to be covalently modifiable")

with open(f"{output_dir}/{pdb_file[:-4]}.pkl", "wb+") as f:
    pickle.dump(results_dict, f)
with open(f"{output_dir}/{pdb_file[:-4]}_results.txt", "w") as f2:
    f2.write(json.dumps(results_dict, indent=4))
