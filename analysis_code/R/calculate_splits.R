library(tidyr)
library(dplyr)

setwd("~/cyscov/R")
source("helpers.R")

dat_list <- lapply(list.files("rds", pattern="cleaned"), 
                   function(x) { readRDS(paste0("rds/",x)) } )
dat_list_names <- gsub("cleaned_|.rds", "", list.files("rds", pattern="cleaned"))
names(dat_list) <- dat_list_names

# generate all seeds
seeds <- sample.int(10000000, 10)
# Seeds Sep 23
# [1] 7221968 3712415 7525423 6281696 7208642 1568132 9786146 1066521 9569592 1022645
# 
# Seeds on Jan 23:
# [1] 9863577  805601 8289448 7181594 5561234 7446627 
# 2016022 1895071 8033491 8650882
# seeds <- c(9863577, 805601, 8289448, 7181594, 5561234, 7446627, 2016022, 1895071, 8033491, 8650882)
#
# use same seeds
#seeds = c(5265133, 7593354, 8367944, 2760789, 6858663, 4414868, 
#          3679243, 6933897, 9423755, 8476297)

# name all formulas
formulas <- list(
  y ~ pka,
  y ~ log_exposure,
  y ~ t1 + t2 + t3 + t4 + t5,
  y ~ st1 + st2 + st3 + st4 + st5 + st6 + st7 + st8,
  y ~ G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + pka,
  y ~ log_exposure + t1 + t2 + t3 + t4 + t5,
  y ~ log_exposure + st1 + st2 + st3 + st4 + st5 + st6 + st7 + st8,
  y ~ log_exposure + pka + t1 + t2 + t3 + t4 + t5,
  y ~ log_exposure + pka + st1 + st2 + st3 + st4 + st5 + st6 + st7 + st8,
  y ~ log_exposure + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + pka + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + top5_fpocket,
  y ~ log_exposure + any_fpocket,
  y ~ log_exposure + top5_fpocket + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + any_fpocket + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + plb_1_sitefinder,
  y ~ log_exposure + plb_0_sitefinder,
  y ~ log_exposure + any_sitefinder,
  y ~ log_exposure + plb_1_sitefinder + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + plb_0_sitefinder + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + any_sitefinder + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + pka + any_sitefinder + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`,
  y ~ log_exposure + pka + any_sitefinder
)
names(formulas) <- c("pKa", "log_exp","t_scales", "st_scales", "aa",
                     "log_exp+pKa","log_exp+t_scales","log_exp+st_scales",
                     "log_exp+pka+t_scales","log_exp+pka+st_scales",
                     "log_exp+aa","log_exp+pka+aa",
                     "log_exp+top5_fpocket", "log_exp+any_fpocket",
                     "log_exp+top5_fpocket+aa", "log_exp+any_fpocket+aa",
                     "log_exp+plb1_sitefinder", "log_exp+plb0_sitefinder",
                     "log_exp+any_sitefinder", "log_exp+plb1_sitefinder+aa", 
                     "log_exp+plb0_sitefinder+aa",
                     "log_exp+any_sitefinder+aa", 
                     "log_exp+pKa+any_sitefinder+aa",
                     "log_exp+pKa+any_sitefinder")

#names(formulas) <- c("pKa", "log_exp", "log_exp+any_fpocket",
#                     "log_exp+any_fpocket+aa",
#                     "log_exp+any_sitefinder",
#                     "log_exp+any_sitefinder+aa")

# for each dataset, create the split then train the models
results_lr <- list()
pr_auc_results_lr <- list()
accuracy_results_lr <- list()

for (name in dat_list_names) {
  # create df to store results
  results_lr[[name]] <- as.data.frame(matrix(nrow=length(seeds), ncol=length(formulas)),
                                      row.names=seeds)
  colnames(results_lr[[name]]) <- names(formulas)
  rownames(results_lr[[name]]) <- as.character(seeds)
  
  pr_auc_results_lr[[name]] <- as.data.frame(matrix(nrow=length(seeds), ncol=length(formulas)),
                                      row.names=seeds)
  colnames(pr_auc_results_lr[[name]]) <- names(formulas)
  rownames(pr_auc_results_lr[[name]]) <- as.character(seeds)
  
  accuracy_results_lr[[name]] <- as.data.frame(matrix(nrow=length(seeds), ncol=length(formulas)),
                                             row.names=seeds)
  colnames(accuracy_results_lr[[name]]) <- names(formulas)
  rownames(accuracy_results_lr[[name]]) <- as.character(seeds)
  
  for (seed in seeds) {
    # create data split
    reactive_cys_data <- dat_list[[name]]
    set.seed(seed); test_genes <- sample(unique(reactive_cys_data$gene),
                                         round(length(unique(reactive_cys_data$gene))/10),
                                         replace=FALSE)
    
    df_train <- reactive_cys_data[-which(reactive_cys_data$gene %in% test_genes),]
    df_test <- reactive_cys_data[which(reactive_cys_data$gene %in% test_genes),]
    
    full_data = list("train"=df_train, "test"=df_test)
    
    # train models
    for (formula_name in names(formulas)) {
      ## first logistic regression
      results_lr[[name]][as.character(seed), formula_name] <-
        calculate_lr_f1(full_data, formulas[[formula_name]])
      pr_auc_results_lr[[name]][as.character(seed), formula_name] <-
        calculate_lr_prauc(full_data, formulas[[formula_name]])
      accuracy_results_lr[[name]][as.character(seed), formula_name] <-
        calculate_lr_accuracy(full_data, formulas[[formula_name]])
      
    }
  }
}

results_types <- list(
  "F1"=results_lr, 
  "AUPRC"=pr_auc_results_lr, 
  "Accuracy"=accuracy_results_lr
)

#saveRDS(results_types, "rds/full_lr_results_sep23.rds")

for (result_name in names(results_types)) {
  tmp_results = results_types[[result_name]]
  
  tmp_lr <- lapply(tmp_results, 
                   function(x) {
                     data.frame(pivot_longer(x, everything()))
                   })
  
  full_results <- data.frame(
    covariates=c(rep(names(formulas), 
                     length.out=length(tmp_lr)*dim(tmp_lr[[1]])[1])),
    dataset=c(rep(dat_list_names, each=length(formulas)*length(seeds), 
                  length.out=length(tmp_lr)*dim(tmp_lr[[1]])[1])),
    seed=c(rep(seeds, each=length(formulas), 
               length.out=length(tmp_lr)*dim(tmp_lr[[1]])[1])),
    metric=c(tmp_lr[[1]]$value, tmp_lr[[2]]$value, tmp_lr[[3]]$value, tmp_lr[[4]]$value,
         tmp_lr[[5]]$value, tmp_lr[[6]]$value, tmp_lr[[7]]$value,
         tmp_lr[[8]]$value, tmp_lr[[9]]$value, tmp_lr[[10]]$value)
  )
  
  g <- ggplot(full_results, 
              aes(covariates, metric)) + 
    #geom_boxplot() + 
    geom_jitter(width=0.2) + 
    ylim(0.1, 0.9) +
    facet_grid(rows=vars(dataset)) +
    ggtitle(paste0(result_name, " scores across 10 random splits")) + 
    theme_bw()
  
  #print(g)
  
  # try plotting means and SDs
  result_means <- aggregate(
    metric ~ covariates + dataset,
    data=full_results,
    FUN=mean)
  
  tmp_result_means <- result_means %>%
    pivot_wider(names_from = dataset, values_from = metric)
  
  #write.csv(tmp_result_means,paste0(result_name, "_splits_results_sep23.csv"),
  #          quote=F)
}

##################### RF

formulas <- list(
  y ~ log_exposure + any_fpocket + G + A + V + L + I + P + M + C + `F` + Y + W +
    H + K + R + Q + N + E + D + S + `T`
)
names(formulas) <- c("log_exp+any_fpocket+aa")


# for each dataset, create the split then train the models
results_rf <- list()
pr_auc_results_rf <- list()
accuracy_results_rf <- list()

for (name in dat_list_names) {
  # create df to store results
  results_rf[[name]] <- as.data.frame(matrix(nrow=length(seeds), ncol=length(formulas)),
                                      row.names=seeds)
  colnames(results_rf[[name]]) <- names(formulas)
  rownames(results_rf[[name]]) <- as.character(seeds)
  
  pr_auc_results_rf[[name]] <- as.data.frame(matrix(nrow=length(seeds), ncol=length(formulas)),
                                             row.names=seeds)
  colnames(pr_auc_results_rf[[name]]) <- names(formulas)
  rownames(pr_auc_results_rf[[name]]) <- as.character(seeds)
  
  accuracy_results_rf[[name]] <- as.data.frame(matrix(nrow=length(seeds), ncol=length(formulas)),
                                               row.names=seeds)
  colnames(accuracy_results_rf[[name]]) <- names(formulas)
  rownames(accuracy_results_rf[[name]]) <- as.character(seeds)
  
  for (seed in seeds) {
    print(seed)
    # create data split
    reactive_cys_data <- dat_list[[name]]
    set.seed(seed); test_genes <- sample(unique(reactive_cys_data$gene),
                                         round(length(unique(reactive_cys_data$gene))/10),
                                         replace=FALSE)
    
    df_train <- reactive_cys_data[-which(reactive_cys_data$gene %in% test_genes),]
    df_test <- reactive_cys_data[which(reactive_cys_data$gene %in% test_genes),]
    
    full_data = list("train"=df_train, "test"=df_test)
    
    # train models
    for (formula_name in names(formulas)) {
      ## first logistic regression
      
      metric_vector <- calculate_rf_metrics(full_data, formulas[[formula_name]])
      
      results_rf[[name]][as.character(seed), formula_name] <-
        metric_vector["f1"]
      pr_auc_results_rf[[name]][as.character(seed), formula_name] <-
        metric_vector["pr_auc"]
      accuracy_results_rf[[name]][as.character(seed), formula_name] <-
        metric_vector["acc"]
      
    }
  }
}

results_types <- list(
  "F1"=results_rf, 
  "AUPRC"=pr_auc_results_rf, 
  "Accuracy"=accuracy_results_rf
)

#saveRDS(results_types, "rds/full_rf_results_sep23.rds")

for (result_name in names(results_types)) {
  tmp_results = results_types[[result_name]]
  
  tmp_rf <- lapply(tmp_results, 
                   function(x) {
                     data.frame(pivot_longer(x, everything()))
                   })
  
  full_results <- data.frame(
    covariates=c(rep(names(formulas), 
                     length.out=length(tmp_rf)*dim(tmp_rf[[1]])[1])),
    dataset=c(rep(dat_list_names, each=length(formulas)*length(seeds), 
                  length.out=length(tmp_rf)*dim(tmp_rf[[1]])[1])),
    seed=c(rep(seeds, each=length(formulas), 
               length.out=length(tmp_rf)*dim(tmp_rf[[1]])[1])),
    metric=c(tmp_rf[[1]]$value, tmp_rf[[2]]$value, tmp_rf[[3]]$value, tmp_rf[[4]]$value,
             tmp_rf[[5]]$value, tmp_rf[[6]]$value, tmp_rf[[7]]$value,
             tmp_rf[[8]]$value, tmp_rf[[9]]$value, tmp_rf[[10]]$value)
  )
  
  g <- ggplot(full_results, 
              aes(covariates, metric)) + 
    #geom_boxplot() + 
    geom_jitter(width=0.2) + 
    ylim(0.1, 0.9) +
    facet_grid(rows=vars(dataset)) +
    ggtitle(paste0(result_name, " scores across 10 random splits")) + 
    theme_bw()
  
  #print(g)
  
  # try plotting means and SDs
  result_means <- aggregate(
    metric ~ covariates + dataset,
    data=full_results,
    FUN=mean)
  
  tmp_result_means <- result_means %>%
    pivot_wider(names_from = dataset, values_from = metric)
  
  #write.csv(tmp_result_means,paste0(result_name, "_splits_results_rf_sep23.csv"),
  #          quote=F)
}


####################

tmp <- dat_list[["NQNC"]]
reslist <- c("G","A","V","L","I","P", "M", "C",
             "F", "Y", "W", "H", "K", "R", "Q", 
             "N", "E", "D", "S", "T")
tmp_df <- data.frame(
  y = tmp$y,
  pdb = tmp$pdbid,
  chain = tmp$chain,
  res = tmp$res,
  gene = tmp$gene,
  log_exp = tmp$log_exposure,
  any_fpocket = tmp$any_fpocket
)
for (id in reslist) {
  tmp_df[id] = sapply(
    tmp$near_res, function(x) {
      length(which(x == id))
    }
  )
}






flat_file_for_Viktor <- dat_list[["SQCT"]][,c(
  "y", "pdbid", "chain", "res", "gene", "log_exposure",
  reslist
)]


neighborhood_sizes <- table(sapply(tmp$near_res, length), tmp$y)

neigh_norm <- neighborhood_sizes
neigh_norm[,1] <- neigh_norm[,1]/sum(which(tmp$y == 0))
neigh_norm[,2] <- neigh_norm[,2]/sum(which(tmp$y == 1))


par(mfrow=c(2,1))
barplot(t(neighborhood_sizes), beside=T, main="Neighborhood size",
        legend=T)
barplot(t(neigh_norm), beside=T, main="Neighborhood size (normalized)",
        legend=T)

median(sapply(tmp[which(tmp$y == 1), "near_res"], length))

median(sapply(tmp[which(tmp$y == 0), "near_res"], length))





df <- dat_list$SQCT

ggplot(df, aes(x=st1-st2+st3, y=log_exposure, color=y)) + 
  geom_point()


df.pca <- prcomp(df[,seq(12,31)], center = TRUE,scale. = TRUE)

summary(df.pca)
par(mfrow=c(1,1))
plot(df.pca$x[,2] ~ df.pca$x[,1], col=c("red", "blue")[df$y],
     xlab="PC1", ylab="PC2", 
     main="Covalent Cysteine PCA over AA neighborhood")
df.pca$rotation[,1]
cor(as.numeric(df$y), df.pca$x[,1])
