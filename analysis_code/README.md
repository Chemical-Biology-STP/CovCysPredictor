# Analysis Code

This directory houses the data and preliminary models for our reactive cysteine prediction tool.

## Running the code

Make sure you either start up the R environment as below, or install the requirements yourself.

```
install.packages("renv")
library("renv")
renv::activate()
```

You should then be able to explore code in the `R` folder.

## Brief descriptions of the various files

* `clean_pocket_data.R`, `cyscov_data_clean.R`: Simple data cleaning
* `calculate_splits.R`: Runs the models
* `using_median_model.R`: Reports the median model performance and saves the coefficients
* `convert_files.R`, `helpers.R`: helper functions
* `paper_figures.R`: Creates paper figures