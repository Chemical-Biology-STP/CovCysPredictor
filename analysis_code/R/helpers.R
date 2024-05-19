library(ROCR) # for receiver operating curve
library(PRROC) # for precision-recall curve, better for imbalanced data
library(randomForest)

precision_local <- function(matrix) {
  # True positive
  tp <- matrix[2, 2]
  # false positive
  fp <- matrix[1, 2]
  return (tp / (tp + fp))
}

recall_local <- function(matrix) {
  # true positive
  tp <- matrix[2, 2]# false positive
  fn <- matrix[2, 1]
  return (tp / (tp + fn))
}

calculate_lr_f1 <- function(full_data, formula, print=FALSE) {
  logit_train <- glm(formula, data=full_data[["train"]], family='binomial')
  
  # create cut-off from train set
  predictions <- predict(logit_train, full_data[["train"]], type='response')
  
  score1=predictions[full_data[["train"]]$y==1]
  score0=predictions[full_data[["train"]]$y==0]
  
  roc <- roc.curve(score1, score0, curve = T)
  
  # use Youden's index (Se + Sp – 1)
  # to calculate optimal cutoff point;
  # where Youden's index is maximal
  
  # curve is how Se ~ (1 - Sp)
  # plot(roc$curve[,2] ~ roc$curve[,1])
  
  # So Youden = Se - (1 - Sp)
  youden = roc$curve[,2] - roc$curve[,1]
  cutoff_ind = which.max(youden)
  cutoff = roc$curve[cutoff_ind,1]
  if(print) {
    print("Cutoff: ")
    print(cutoff)
  }
  
  predictions <- predict(logit_train, full_data[["test"]], type='response')
  
  table_mat <- table(full_data[["test"]]$y, predictions > cutoff)
  
  if(print) {print(table_mat)}
  
  prec <- precision_local(table_mat)
  rec <- recall_local(table_mat)
  f1 <- 2 * ((prec * rec) / (prec + rec))
  return(f1)
}

calculate_lr_accuracy <- function(full_data, formula, print=FALSE) {
  logit_train <- glm(formula, data=full_data[["train"]], family='binomial')
  
  # create cut-off from train set
  predictions <- predict(logit_train, full_data[["train"]], type='response')
  
  score1=predictions[full_data[["train"]]$y==1]
  score0=predictions[full_data[["train"]]$y==0]
  
  roc <- roc.curve(score1, score0, curve = T)
  
  # use Youden's index (Se + Sp – 1)
  # to calculate optimal cutoff point;
  # where Youden's index is maximal
  
  # curve is how Se ~ (1 - Sp)
  # plot(roc$curve[,2] ~ roc$curve[,1])
  
  # So Youden = Se - (1 - Sp)
  youden = roc$curve[,2] - roc$curve[,1]
  cutoff_ind = which.max(youden)
  cutoff = roc$curve[cutoff_ind,1]
  if(print) {
    print("Cutoff: ")
    print(cutoff)
  }
  
  predictions <- predict(logit_train, full_data[["test"]], type='response')
  
  table_mat <- table(full_data[["test"]]$y, predictions > cutoff)
  
  if(print) {print(table_mat)}
  
  tp <- table_mat[1, 1]
  fp <- table_mat[1, 2]
  fn <- table_mat[2, 1]
  tn <- table_mat[2, 2]
  
  accuracy = (tp + tn) / (tp + tn + fp + fn)

  return(accuracy)
}

calculate_lr_prauc <- function(full_data, formula) {
  logit_train <- glm(formula, data=full_data[["train"]], family='binomial')
  
  # create cut-off from train set
  predictions <- predict(logit_train, full_data[["train"]], type='response')
  
  score1=predictions[full_data[["train"]]$y==1]
  score0=predictions[full_data[["train"]]$y==0]
  
  roc <- roc.curve(score1, score0, curve = T)
  
  # use Youden's index (Se + Sp – 1)
  # to calculate optimal cutoff point;
  # where Youden's index is maximal
  
  # curve is how Se ~ (1 - Sp)
  # plot(roc$curve[,2] ~ roc$curve[,1])
  
  # So Youden = Se - (1 - Sp)
  youden = roc$curve[,2] - roc$curve[,1]
  cutoff_ind = which.max(youden)
  cutoff = roc$curve[cutoff_ind,1]
  
  predictions <- predict(logit_train, full_data[["test"]], type='response')
  
  table_mat <- table(full_data[["test"]]$y, predictions > cutoff)
  
  score1=predictions[full_data[["test"]]$y==1]
  score0=predictions[full_data[["test"]]$y==0]
  
  pr <- pr.curve(score1, score0, curve = F)
  
  prec <- precision_local(table_mat)
  rec <- recall_local(table_mat)
  f1 <- 2 * ((prec * rec) / (prec + rec))
  #return(f1)
  
  return(pr$auc.integral)
}

calculate_rf_metrics <- function(full_data, formula) {
  rf <- randomForest(formula, data=full_data[["train"]], 
                     classwt=c(4,1),
                     proximity=TRUE)
  
  pred_test <- predict(rf, full_data[["test"]])
  table_mat <- table(full_data[["test"]]$y, pred_test == 1)
  
  prec <- precision_local(table_mat)
  rec <- recall_local(table_mat)
  f1 <- 2 * ((prec * rec) / (prec + rec))
  
  score1=pred_test[full_data[["test"]]$y==1]
  score0=pred_test[full_data[["test"]]$y==0]
  
  pr <- pr.curve(score1, score0, curve = F)
  
  tp <- table_mat[1, 1]
  fp <- table_mat[1, 2]
  fn <- table_mat[2, 1]
  tn <- table_mat[2, 2]
  
  accuracy = (tp + tn) / (tp + tn + fp + fn)
  
  return(c("f1"=f1, "pr_auc"=pr$auc.integral, "acc"=accuracy))
}

parse_residues <- function(res_string) {
  res_ids <- lapply(strsplit(res_string, "|", fixed=T), function(x){gsub(".*_", "", x)})
  res_names <- lapply(res_ids, function(x){substr(x, 1, 1)})
  return(res_names)
}
