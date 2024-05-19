This tool can be run using the following command:

/da/CADD/covcyspredictor/run_cysteine_prediction.sh ./my_input_dir/AF-NFKBIB-Q15653.pdb ./my_output_dir/

Things to note:

- You will need a conda installation that is compatible with PythonDSv0.x.
  If you are getting an error that pymol cannot be found, for example,
  try `conda deactivate` on your command line interface and then try the script again.
- The output directory will contain plain text results, as well as the same results in a pkl file 
  (a Python binary file) and an rds file (an R binary file). If you want to visualize your results easily,
  I recommend using my RShiny tool available internally, which requires the relevant PDB file and the *rds* file:
  https://usca-rsconnect-app.prd.nibr.novartis.net/connect/#/apps/68f0277a-b777-4b8c-9b31-74c1a28287f6/
- Visit go/covcyspredictor for more information
