import pymol
from pymol import cmd, stored
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
print("Also note that only the FIRST chain in the PDB file is analyzed!")

### CONSTANTS and DATA

# regression constants
# calculated from median-performing model
# predicting y ~ log_exp + any_fpocket + aa
# NQNC model from CB

beta_0 = -7.448316  # intercept
beta_log_exp = 1.178814
beta_any_fpocket = 2.749349
beta_aa_dict = {
    "A": 0.294973,
    "R": 0.124579,
    "N": 0.150297,
    "D": -0.452443,
    "C": -0.569417,
    "Q": -0.090426,
    "E": -0.047014,
    "G": 0.561154,
    "H": 0.850997,
    "I": -0.248784,
    "L": 0.322118,
    "K": 0.157677,
    "M": -0.287690,
    "F": 0.340038,
    "P": -0.203428,
    "S": 0.266783,
    "T": -0.007631,
    "W": 1.041042,
    "Y": 0.535418,
    "V": -0.127285
}
cutoff = 0.1508668

### CALCULATED PROPERTIES

# calculate solvent-accessible surface area
# and amino acid neighborhood
cmd.set('dot_solvent', 1)
cmd.set('dot_density', 3)

cmd.load(f"{output_dir}/{pdb_file}")  # use the name of your pdb file

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
