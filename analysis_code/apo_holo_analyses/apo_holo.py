# Bryn Reimer
# 2024
# Analysing apo/holo pairs
import json
import os
import pandas as pd


os.chdir("/Users/brynr/Desktop/CovCysPredictor")

pairs = [
    ["3zva", "3zv8"],
    ["5rfo", "5r8t"],
    ["7b9m", "6y58"],
    ["7brp", "7bro"],
    ["1uk4", "1uk3"],
    ["1a54", "1a55"],
    ["3v4o", "3v55"],
    ["1cte", "1cpj"],
    ["6yl1", "6yl6"],
    ["3o6t", "3nof"],
    ["1meg", "1ppo"]
]
data = {}
files = [x for x in os.listdir("./outputs/") if "txt" in x]

df = pd.read_csv("./analysis_code/apo_holo_analyses/apo_holo.txt")

for file in files:
    with open(f"./outputs/{file}") as f:
        data[file.replace("_results.txt", "")] = json.load(f)

positive_ctrl = df[df['y'] == 1]
for pair in pairs:
    print(pair)
    print(positive_ctrl[positive_ctrl['pdbid'] == pair[0]])
    for k in data[pair[0]].keys():
        print(f"{k}: (holo) {data[pair[0]][k]['score']}, "
               f"mod? {data[pair[0]][k]["predicted_modifiable"]}", end = " ")
        if k in data[pair[1]].keys():
            print(f"- (apo) {data[pair[1]][k]['score']}, "
                  f"mod? {data[pair[1]][k]["predicted_modifiable"]}")
        else:
            print("(not in apo)")
