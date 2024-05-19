library(tidyr)
library(dplyr)
library(ggplot2)
library(ggbeeswarm)

setwd("~/cyscov/R")
source("helpers.R")



######## 
# 
# First set of paper figures
# Exploratory on NQNC dataset after cleaning
#
########

cleaned_NQNC <- readRDS("./rds/cleaned_NQNC.rds")
length(unique(cleaned_NQNC$pdbid))
# [1] 886 

# pKa
plot(cleaned_NQNC$pka ~ cleaned_NQNC$y)
cor.test(cleaned_NQNC$pka, as.numeric(cleaned_NQNC$y))

cleaned_NQNC$yes_no <- c("no","yes")[as.numeric(cleaned_NQNC$y)]

sample_size = cleaned_NQNC %>% group_by(yes_no) %>% summarize(num=n())

cleaned_NQNC %>%
  left_join(sample_size) %>%
  mutate(myaxis=paste0(yes_no, "\n", "n=", num)) %>%
  ggplot(aes(x=myaxis, y=pka, fill=yes_no)) + 
  geom_violin() + 
  geom_boxplot(width=0.1, alpha=0.8, fill="white") + 
  geom_abline(intercept=8.5, slope=0) +
  ggtitle("Bound Cysteines Exhibit \n Lower Predicted pKa") +
  labs(size=10,
       x="Bound Cysteine",
       y="pKa values") + 
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

# solvent exposure
plot(cleaned_NQNC$exposure ~ cleaned_NQNC$y)
plot(cleaned_NQNC$log_exposure ~ cleaned_NQNC$y)
cor.test(cleaned_NQNC$exposure, as.numeric(cleaned_NQNC$y))
cor.test(cleaned_NQNC$log_exposure, as.numeric(cleaned_NQNC$y))

cleaned_NQNC %>%
  left_join(sample_size) %>%
  mutate(myaxis=paste0(yes_no, "\n", "n=", num)) %>%
  ggplot(aes(x=myaxis, y=exposure, fill=yes_no)) + 
  geom_violin() + 
  geom_boxplot(width=0.1, alpha=0.8, fill="white") + 
  ggtitle("Bound cysteines are more \n solvent accessible") +
  labs(size=10,
       x="Bound Cysteine",
       y="% Solvent Exposure") + 
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

cleaned_NQNC %>%
  left_join(sample_size) %>%
  mutate(myaxis=paste0(yes_no, "\n", "n=", num)) %>%
  ggplot(aes(x=myaxis, y=log_exposure, fill=yes_no)) + 
  geom_violin() + 
  geom_boxplot(width=0.1, alpha=0.8, fill="white") + 
  ggtitle("Using log solvent exposure \n reveals significant differences") +
  labs(size=10,
       x="Bound Cysteine",
       y="Log % Solvent Exposure") + 
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

# local aa environment
tmp <- princomp(cleaned_NQNC[,c("st1","st2","st3","st4","st5","st6","st7","st8")])
plot(tmp$scores[,"Comp.1"], tmp$scores[,"Comp.2"], col=cleaned_NQNC$y)
cor.test(tmp$scores[,"Comp.1"], as.numeric(cleaned_NQNC$y))
cor.test(tmp$scores[,"Comp.2"], as.numeric(cleaned_NQNC$y))

tmp_scores_df <- as.data.frame(apply(tmp$scores, c(1,2), as.numeric))
tmp_scores_df$yes_no <- cleaned_NQNC$yes_no

tmp_scores_df %>%
  ggplot(aes(x=Comp.1, y=Comp.2, color=yes_no)) + 
  geom_point(alpha=0.3) + 
  ggtitle("ST-scale PCA") +
  labs(size=10,
       x="PC1 (62.7%)",
       y="PC2 (14.1%)") + 
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )


tmp <- princomp(cleaned_NQNC[,c("t1","t2","t3","t4","t5")])
plot(tmp$scores[,"Comp.1"], tmp$scores[,"Comp.2"], col=cleaned_NQNC$y)
cor.test(tmp$scores[,"Comp.1"], as.numeric(cleaned_NQNC$y))
cor.test(tmp$scores[,"Comp.2"], as.numeric(cleaned_NQNC$y))

tmp_scores_df <- as.data.frame(apply(tmp$scores, c(1,2), as.numeric))
tmp_scores_df$yes_no <- cleaned_NQNC$yes_no

tmp_scores_df %>%
  ggplot(aes(x=Comp.1, y=Comp.2, color=yes_no)) + 
  geom_point(alpha=0.3) + 
  ggtitle("T-scale PCA") +
  labs(size=10,
       x="PC1 (77.1%)",
       y="PC2 (13.8%)") + 
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

tmp <- princomp(cleaned_NQNC[,c("G","A","V","L","I","P", "M","C","F","Y","W","H","K","R","Q","N","E","D","S","T")])
plot(tmp$scores[,"Comp.1"], tmp$scores[,"Comp.2"], col=cleaned_NQNC$y)
cor.test(tmp$scores[,"Comp.1"], as.numeric(cleaned_NQNC$y))
cor.test(tmp$scores[,"Comp.2"], as.numeric(cleaned_NQNC$y))

tmp_scores_df <- as.data.frame(apply(tmp$scores, c(1,2), as.numeric))
tmp_scores_df$yes_no <- cleaned_NQNC$yes_no

tmp_scores_df %>%
  ggplot(aes(x=Comp.1, y=Comp.2, color=yes_no)) + 
  geom_point(alpha=0.3) + 
  ggtitle("One-Hot AA PCA") +
  labs(size=10,
       x="PC1 (15.3%)",
       y="PC2 (10.0%)") + 
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

# pockets
table(cleaned_NQNC$any_fpocket, cleaned_NQNC$y)
table(cleaned_NQNC$any_sitefinder, cleaned_NQNC$y)

cor.test(as.numeric(cleaned_NQNC$any_fpocket), as.numeric(cleaned_NQNC$y))
cor.test(as.numeric(cleaned_NQNC$any_sitefinder), as.numeric(cleaned_NQNC$y))




######################
#
# Section 2: QuickPrep and Rosetta repacking don't help accuracy
#
######################

lr_results <- readRDS("./rds/full_lr_results_sep23.rds")

formulas <- lr_results[["F1"]][["NQNC"]]
seeds <- rownames(lr_results[["F1"]][["NQNC"]])

for (result_name in names(lr_results)) {
  tmp_results = lr_results[[result_name]]
  
  tmp_lr <- lapply(tmp_results, 
                   function(x) {
                     data.frame(pivot_longer(x, cols=everything(), names_to="formula"))
                   })
  
  full_results <- data.frame(
    covariates=c(rep(names(formulas), 
                     length.out=length(tmp_lr)*dim(tmp_lr[[1]])[1])),
    dataset=c(rep(names(tmp_results), each=length(formulas)*length(seeds), 
                  length.out=length(tmp_lr)*dim(tmp_lr[[1]])[1])),
    seed=c(rep(seeds, each=length(formulas), 
               length.out=length(tmp_lr)*dim(tmp_lr[[1]])[1])),
    metric=c(tmp_lr[[1]]$value, tmp_lr[[2]]$value, tmp_lr[[3]]$value, tmp_lr[[4]]$value,
             tmp_lr[[5]]$value, tmp_lr[[6]]$value, tmp_lr[[7]]$value,
             tmp_lr[[8]]$value, tmp_lr[[9]]$value, tmp_lr[[10]]$value)
  )
  
  full_results$dataset <- factor(full_results$dataset, 
                                 levels=c("NQNC","SQCT","SQCA","DQCT","DQCA",
                                          "DQCA_RR10_noqkprep", "DQCA_RR10",
                                          "CB_NQNC","CB_DQCT","CB_SQCT"))
  full_results$covariates <- factor(full_results$covariates,
                                    levels=c("pKa", "log_exp", "aa", 
                                             "log_exp+pKa",
                                             "log_exp+aa"))
  
  for(ds in c("SQCT","SQCA","DQCT","DQCA")) {
    for(cov in c("pKa", "log_exp", "aa", 
                 "log_exp+pKa",
                 "log_exp+aa")) {
      t1 <- full_results[which(full_results$dataset %in% 
                                c("NQNC") &
                               full_results$covariates %in% 
                                c(cov)),"metric"]
      t2 <- full_results[which(full_results$dataset %in% 
                                 c(ds) &
                               full_results$covariates %in% 
                                 c(cov)),"metric"]
      
      print(paste0(ds, " ", cov, " ", t.test(t1, t2)$p.value))
    }
  }
  
  # for F1 score, the only sig different to NQNC are:
  # DQCA log_exp (worse) 
  # SQCA log_exp (worse)
  #
  #
  
  g <- ggplot(full_results[which(full_results$dataset %in% 
                                   c("NQNC","SQCT","SQCA","DQCT","DQCA") &
                                    full_results$covariates %in% 
                                     c("pKa", "log_exp", "aa", 
                                       "log_exp+pKa",
                                       "log_exp+aa")),], 
              aes(dataset, metric)) + 
    geom_boxplot() + 
    ylab(result_name) +
    facet_grid(rows=vars(covariates)) +
    ggtitle(paste0(result_name, " scores across 10 random splits")) + 
    theme_bw(
    )  +
    theme(
      legend.position="none",
      plot.title=element_text(size=15),
      axis.text=element_text(size=10),
      axis.title=element_text(size=12)
    )
  
  print(g)
  
  for(ds in c("DQCA","DQCA_RR10_noqkprep","DQCA_RR10")) {
    for(cov in c("pKa", "log_exp", "aa", 
                 "log_exp+pKa",
                 "log_exp+aa")) {
      t1 <- full_results[which(full_results$dataset %in% 
                                 c("NQNC") &
                                 full_results$covariates %in% 
                                 c(cov)),"metric"]
      t2 <- full_results[which(full_results$dataset %in% 
                                 c(ds) &
                                 full_results$covariates %in% 
                                 c(cov)),"metric"]
      
      print(paste0(ds, " ", cov, " ", t.test(t1, t2)$p.value))
    }
  }
  
  g <- ggplot(full_results[which(full_results$dataset %in% 
                                   c("NQNC","DQCA","DQCA_RR10_noqkprep","DQCA_RR10") &
                                   full_results$covariates %in% 
                                   c("pKa", "log_exp", "aa", 
                                     "log_exp+pKa",
                                     "log_exp+aa")),], 
              aes(dataset, metric)) + 
    geom_boxplot() + 
    ylab(result_name) +
    facet_grid(rows=vars(covariates)) +
    ggtitle(paste0(result_name, " scores across 10 random splits")) + 
    theme_bw(
    )  +
    theme(
      legend.position="none",
      plot.title=element_text(size=15),
      axis.text=element_text(size=10),
      axis.title=element_text(size=12)
    )
  
  print(g)
  
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

### looking at differences between DQCA and DQCA_RR10

dqca_dat <- readRDS("rds/cleaned_DQCA.rds")
dqca_rr10_dat <- readRDS("rds/cleaned_DQCA_RR10.rds")
in.common <- dqca_dat$pdbid_chain_res[which(
  dqca_dat$pdbid_chain_res %in% dqca_rr10_dat$pdbid_chain_res
)]

rownames(dqca_dat) <- dqca_dat$pdbid_chain_res
rownames(dqca_rr10_dat) <- dqca_rr10_dat$pdbid_chain_res

dqca_dat_subset <- dqca_dat[in.common,]
dqca_rr10_dat_subset <- dqca_rr10_dat[in.common,]

plot_df_all <- data.frame(difftype = 
                            c(rep("pKa", nrow(dqca_dat_subset)),
                              rep("exposure", nrow(dqca_dat_subset))),
                          y = c(dqca_dat_subset$y, dqca_dat_subset$y),
                          value = c(dqca_dat_subset$pka - 
                            dqca_rr10_dat_subset$pka,
                            dqca_dat_subset$exposure - 
                            dqca_rr10_dat_subset$exposure))
plot_df_all$difftype <- factor(plot_df_all$difftype, levels=c("pKa","exposure"))

ggplot(plot_df_all, aes(x=difftype, y=value)) +
  geom_violin(fill="#C77CFF") + 
  ylab("Difference after repacking") + 
  xlab("Feature") +
  ggtitle("Distribution of differences \n before and after repacking") + 
  theme_bw(
  )  +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

ggplot(plot_df_all[which(plot_df_all$y == 0),], aes(x=difftype, y=value)) +
  geom_violin(fill="#F8776D") + 
  ylab("Difference after repacking") + 
  xlab("Feature") +
  ggtitle("Distribution of differences \n before and after repacking: 
          Only unbound cysteines") + 
  theme_bw(
  )  +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )

ggplot(plot_df_all[which(plot_df_all$y == 1),], aes(x=difftype, y=value)) +
  geom_violin(fill="#00BFC4") + 
  ylab("Difference after repacking") + 
  xlab("Feature") +
  ggtitle("Distribution of differences \n before and after repacking: 
          Only bound cysteines") + 
  theme_bw(
  )  +
  theme(
    legend.position="none",
    plot.title=element_text(size=15),
    axis.text=element_text(size=10),
    axis.title=element_text(size=12)
  )



######### NQNC model choices

#nqnc_results <- lr_results[["F1"]][["NQNC"]]

apply(nqnc_results, 2, median)
#  log_exp+any_sitefinder+aa
#  0.7303811

which.min(abs(nqnc_results$`log_exp+any_sitefinder+aa` - median(nqnc_results$`log_exp+any_sitefinder+aa`)))
# 1
# seed = 7221968
