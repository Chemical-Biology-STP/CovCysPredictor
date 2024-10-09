# move from pymol to biopython
from Bio.PDB import PDBParser
from Bio.PDB.SASA import ShrakeRupley
from Bio.SeqUtils import seq1
import math
import sys
import pickle
import json

# informs Biopython that we don't mind its warnings
from Bio.PDB.PDBParser import PDBConstructionWarning
import warnings

### INPUT

if len(sys.argv) < 3:
    print("Must input exactly one PDB file name and one output directory")
    print("e.g. `python ./CovCysPredictor.py my_file.pdb output_dir/`")
    sys.exit()
pdb_file = sys.argv[1]
output_dir = sys.argv[2] 

print("Running prediction...")

### CONSTANTS and DATA

# regression constants
# calculated from median-performing model
# predicting y ~ intercept + log_exp + any_fpocket + aa
# NQNC model from CB
with open('coefficients.json', 'r') as file:
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
with warnings.catch_warnings():
    warnings.simplefilter('ignore', PDBConstructionWarning)
    structure = parser.get_structure("protein", f"{output_dir}/{pdb_file}")

# Structure MUST be cleaned in advance MANUALLY (or with other pipeline)
# No: nucleic acids, ions, cofactors, solvents, etc
# remove organic
# remove inorganic
# remove polymer.nucleic
# remove solvent

sasa_calculator = ShrakeRupley()
sasa_calculator.compute(structure)

# all chains (or non-contiguous polypeptides) will be used together
# define a helper method to get neighbors given a cysteine residue
def get_neighbors(structure, cys, radius):
    neighbors = []
    for resid in structure.get_residues():
        if resid.__contains__("CA") and (resid["CA"] - cys["SG"] <= radius):
            if resid["CA"] - cys["CA"] > 0.0001: # not the cysteine alpha carbon
                neighbors.append(seq1(resid.get_resname()))

    return neighbors


### FPOCKET HELPER
with open(f"{output_dir}/cysteines_in_fpocket_{pdb_file[:-4]}.log") as fi:
    tmp_cys_in_fpocket = fi.readlines()

cys_in_fpocket = [l.strip('\n') for l in tmp_cys_in_fpocket]


# store a list of cysteine residues
stored_cysteine_residues = {
    f"{ch.get_id()} {x.get_id()[1]}": {
        "chain": ch.get_id(),
        "resid": x.get_id()[1],
        "sasa": x["SG"].sasa,
        "log_exp": math.log(x["SG"].sasa + 1),
        "any_fpocket": int(f"{ch.get_id()} {x.get_id()[1]}" in cys_in_fpocket),
        "neighbors": get_neighbors(structure, x, 8) # counts all neighbors w/ an alpha carbon
                                                           # w/in "radius" angstroms; one-letter codes
    } for ch in structure.get_chains() for x in ch.get_residues() if x.get_resname() == "CYS"
}

### PREDICTION ENGINE
for k,v in stored_cysteine_residues.items():
    # apply beta coefficients to calculated properties
    nu = beta_0 + beta_log_exp*v["log_exp"] + beta_any_fpocket*v["any_fpocket"] + \
         sum(v["neighbors"].count(aa)*beta_aa_dict[aa]
             for aa in list(set(v["neighbors"]))
             if aa in beta_aa_dict.keys())

    # logistic link function
    mu = math.exp(nu)/(1 + math.exp(nu))
    v["score"] = f"{mu:.2}"
    if mu >= cutoff:
        v["predicted_modifiable"] = True
        #print("--> LIKELY to be covalently modifiable")
    else:
        v["predicted_modifiable"] = False

with open(f"{output_dir}/{pdb_file[:-4]}.pkl", "wb+") as f:
    pickle.dump(stored_cysteine_residues, f)
with open(f"{output_dir}/{pdb_file[:-4]}_results.txt", "w") as f2:
    f2.write(json.dumps(stored_cysteine_residues, indent=4))

print("Prediction complete!")
print(stored_cysteine_residues)