library(tidyr)
library(dplyr)
library(ggplot2)
library(ggbeeswarm)

setwd("~/cyscov/R")
source("helpers.R")

dat_list <- lapply(list.files("rds", pattern="cleaned"), 
                   function(x) { readRDS(paste0("rds/",x)) } )
dat_list_names <- gsub("cleaned_|.rds", "", list.files("rds", pattern="cleaned"))
names(dat_list) <- dat_list_names

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

# median model
set.seed(7221968); test_genes <- sample(unique(tmp_df$gene), 
                                        round(length(unique(tmp_df$gene))/10),
                                        replace=FALSE)

df_train <- tmp_df[-which(tmp_df$gene %in% test_genes),]
df_test <- tmp_df[which(tmp_df$gene %in% test_genes),]

formula <- y ~ log_exp + any_fpocket + G + A + V + L + I + P + M + C + `F` + Y + W +
  H + K + R + Q + N + E + D + S + `T`

print(formula)
logit_train <- glm(formula, data=df_train, family='binomial')

full_data = list("train"=df_train, "test"=df_test)

predictions <- predict(logit_train, full_data[["test"]], type='response')
calculate_lr_f1(full_data, formula, print=TRUE)
# [1] "Cutoff: "
#[1] 0.1445422

#FALSE TRUE
#0   445   68
#1     9  144
#[1] 0.7890411

# coefficients
logit_train

####

# get PDBIDs from CovPDB not in CovBinderInPDB
cleaned_cb_nqnc <- readRDS("rds/cleaned_CB_NQNC.rds")
cleaned_cb_nqnc_no_dups <- cleaned_cb_nqnc[-which(cleaned_cb_nqnc$pdbid %in% unique(tmp_df$pdb)),]
cleaned_cb_nqnc_no_dups$log_exp <- cleaned_cb_nqnc_no_dups$log_exposure
predictions_ind <- predict(logit_train, cleaned_cb_nqnc_no_dups, type='response')

cutoff = 0.1445422

table_mat <- table(cleaned_cb_nqnc_no_dups$y, predictions_ind > cutoff)

print(table_mat)

prec <- precision_local(table_mat)
rec <- recall_local(table_mat)
f1 <- 2 * ((prec * rec) / (prec + rec))
f1
# [1] 0.6604597

score1=predictions_ind[cleaned_cb_nqnc_no_dups$y==1]
score0=predictions_ind[cleaned_cb_nqnc_no_dups$y==0]

pr <- pr.curve(score1, score0, curve = F)
pr$auc.integral
#[1] 0.7811205

tp <- table_mat[1, 1]
fp <- table_mat[1, 2]
fn <- table_mat[2, 1]
tn <- table_mat[2, 2]

accuracy = (tp + tn) / (tp + tn + fp + fn)
accuracy
