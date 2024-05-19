library(e1071)
library(ggplot2)

precision <- function(matrix) {
  # True positive
  tp <- matrix[2, 2]
  # false positive
  fp <- matrix[1, 2]
  return (tp / (tp + fp))
}

recall <- function(matrix) {
  # true positive
  tp <- matrix[2, 2]# false positive
  fn <- matrix[2, 1]
  return (tp / (tp + fn))
}

dat1d <- readRDS("cleaned_dat1d.rds")
dat2d <- readRDS("cleaned_dat2d.rds")

test_genes <- sample(unique(dat1d$gene), 
                      round(length(unique(dat1d$gene))/10),
                      replace=FALSE)

df_train <- dat1d[-which(dat1d$gene %in% test_genes),]
df_test <- dat1d[which(dat1d$gene %in% test_genes),]

model <- svm(y ~ log_exposure + pka + st1 + st2 + st3 + st4 + st5, data=df_train, 
             kernal="radial")
print(model)
summary(model)

pred <- predict(model, df_test)
tabl <- table(pred, df_test$y)

prec <- precision(tabl)
rec <- recall(tabl)
f1 <- (2 * (prec * rec)) / (prec + rec)
print(f1)

df_test$pred <- pred

ggplot(df_test, aes(x=pka, y=log_exposure, color=pred, shape=y)) + 
  geom_point()

