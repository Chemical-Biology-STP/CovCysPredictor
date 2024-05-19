# based on average splits performance
# between dat1/d, dat2/d, and rosetta10

reactive_cys_data <- readRDS("cleaned_dat1.rds")

# chosen for closest to median performance
set.seed(4414868); test_genes <- sample(unique(reactive_cys_data$gene), 
                                        round(length(unique(reactive_cys_data$gene))/10),
                                        replace=FALSE)

df_train <- reactive_cys_data[-which(reactive_cys_data$gene %in% test_genes),]
df_test <- reactive_cys_data[which(reactive_cys_data$gene %in% test_genes),]

formula <- y ~ log_exposure + st1 + st2 + st3 + st4 + st5 + st6 + st7 + st8

print(formula)
logit_train <- glm(formula, data=df_train, family='binomial')

full_data = list("train"=df_train, "test"=df_test)

predictions <- predict(logit_train, full_data[["test"]], type='response')
calculate_lr_f1(full_data, formula)

logit_train

predictions <- predict(logit_train, full_data[["train"]][which(full_data[["train"]]$pdbid == "1ecg"),], type='response')
