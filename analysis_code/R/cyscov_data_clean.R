setwd("~/cyscov/R")

library(dplyr)
library(broom) # for PCA, tidy style
library(ggplot2)
library(ggbeeswarm)
library(Peptides) # for generating ST-scale and T-scale

source("helpers.R")

cleaned_fpocket <- readRDS("rds/fpocket.rds")
cleaned_sitefinder <- readRDS("rds/sitefinder.rds")

SQCA_raw <- read.csv("../data/SQCA/pdbs_cys_allinfo_SQCA.csv")
SQCT_raw <- read.csv("../data/SQCT/pdbs_cys_allinfo_data2_v1-protocol.csv")

DQCA_raw <- read.csv("../data/DQCA/pdbs_cys_allinfo_cutoff_none.csv")
DQCT_raw <- read.csv("../data/DQCT/pdbs_cys_allinfo.csv")

DQCA_RR10 <- read.csv("../data/DQCA_RR/pdbs_cys_allinfo_cutoff_10A.csv")
DQCA_RR10_noqkprep <- read.csv("../data/DQCA_RR_no_final_qkprep/pdbs_cys_rosetta_10A.csv")

NQNC_raw <- read.csv("../data/NQNC/NQNC_receptor_cys_allinfo.csv")

CovBinder_NQNC_raw <- read.csv("../data/CovBinder_NQNC/pdbs_cys_allinfo_NQNC_CovBinderInPDB-data.csv")
CovBinder_SQCT_raw <- read.csv("../data/CovBinder_SQCT/pdbs_cys_allinfo_SQCT_CovBinderInPDB-data.csv")
CovBinder_DQCT_raw <- read.csv("../data/CovBinder_DQCT/pdbs_cys_allinfo_DQCT_CovBinderInPDB-data.csv")

dat_list = list(
  NQNC_raw,
  SQCA_raw,
  SQCT_raw,
  DQCA_raw,
  DQCT_raw,
  DQCA_RR10,
  DQCA_RR10_noqkprep,
  CovBinder_NQNC_raw,
  CovBinder_SQCT_raw,
  CovBinder_DQCT_raw
)
dat_list_names = c("NQNC", "SQCA", "SQCT", "DQCA","DQCT",
                   "DQCA_RR10", "DQCA_RR10_noqkprep",
                   "CB_NQNC", "CB_SQCT", "CB_DQCT")
names(dat_list) <- dat_list_names

for (name in dat_list_names) {
  dat <- dat_list[[name]]
  print(name)
  subset_dat <- dat[which(dat$ligand.type != "other"),]
  print(dim(subset_dat))
  
  df <- data.frame(y=as.factor(c(1,0)[as.factor(subset_dat$ligand.type)]))
  df$exposure <- subset_dat$X.Exposure
  df$log_exposure <- log(df$exposure + 1)
  df$res <- subset_dat$Res
  df$pdbid <- as.factor(substr(subset_dat$PDBID.chain, 0,4))
  df$chain <- as.factor(substr(subset_dat$PDBID.chain, 6, 6))
  
  df$pdbid_chain_res <- paste0(df$pdbid, "_", df$chain, "_", df$res)
  if (name == "NQNC") {
    df$top5_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["fpocket_noqkprep_top5"]])
    df$any_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["fpocket_noqkprep_any"]])
  } else if (name == c("CB_NQNC")) {
    df$top5_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["CovBinder_fpocket_noqkprep_top5"]])
    df$any_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["CovBinder_fpocket_noqkprep_any"]])
  } else if (name %in% c("CB_SQCT", "CB_DQCT")) {
    df$top5_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["CovBinder_fpocket_qkprep_top5"]])
    df$any_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["CovBinder_fpocket_qkprep_any"]])
  } else {
    df$top5_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["fpocket_qkprep_top5"]])
    df$any_fpocket <- as.integer(df$pdbid_chain_res %in% cleaned_fpocket[["fpocket_qkprep_any"]])
  }
  
  if (name == "NQNC") {
    df$plb_1_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["sitefinder_receptor_sites_plb_1"]])
    df$plb_0_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["sitefinder_receptor_sites_plb_0"]])
    df$any_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["sitefinder_receptor_sites_any"]])
  } else if (name == c("CB_NQNC")) {
    df$plb_1_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["CovBinder_sitefinder_receptor_sites_plb_1"]])
    df$plb_0_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["CovBinder_sitefinder_receptor_sites_plb_0"]])
    df$any_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["CovBinder_sitefinder_receptor_sites_any"]])
  } else if (name %in% c("CB_SQCT", "CB_DQCT")) {
    df$plb_1_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["CovBinder_sitefinder_receptor_qkprep_sites_plb_1"]])
    df$plb_0_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["CovBinder_sitefinder_receptor_qkprep_sites_plb_0"]])
    df$any_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["CovBinder_sitefinder_receptor_qkprep_sites_any"]])
  } else {
    df$plb_1_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["sitefinder_receptor_qkprep_sites_plb_1"]])
    df$plb_0_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["sitefinder_receptor_qkprep_sites_plb_0"]])
    df$any_sitefinder <- as.integer(df$pdbid_chain_res %in% cleaned_sitefinder[["sitefinder_receptor_qkprep_sites_any"]])
  }
  
  df$pka <- subset_dat$pKa
  df$gene <- as.factor(subset_dat$Uniprot.Name)
  df$near_res <- parse_residues(subset_dat$NearRes)
  
  st_scales <- stScales(sapply(df$near_res, function(x){paste0(x[which(x!="X")], collapse="")}))
  t_scales <- tScales(sapply(df$near_res, function(x){paste0(x[which(x!="X")], collapse="")}))
  
  df$catalytic <- sapply(df$near_res, function(x) {
    grepl("HN", paste0(x, collapse=""))
  })
  df$has_h <- sapply(df$near_res, function(x) {
    grepl("H", paste0(x, collapse=""))
  })
  
  reslist <- c("G","A","V","L","I","P", "M", "C",
               "F", "Y", "W", "H", "K", "R", "Q", 
               "N", "E", "D", "S", "T")
  for (id in reslist) {
    df[id] = sapply(
      df$near_res, function(x) {
        length(which(x == id))
      }
    )
  }
  
  df$st1 <- unlist(st_scales)[seq(1, length(unlist(st_scales)), by=8)]
  df$st2 <- unlist(st_scales)[seq(2, length(unlist(st_scales)), by=8)]
  df$st3 <- unlist(st_scales)[seq(3, length(unlist(st_scales)), by=8)]
  df$st4 <- unlist(st_scales)[seq(4, length(unlist(st_scales)), by=8)]
  df$st5 <- unlist(st_scales)[seq(5, length(unlist(st_scales)), by=8)]
  df$st6 <- unlist(st_scales)[seq(6, length(unlist(st_scales)), by=8)]
  df$st7 <- unlist(st_scales)[seq(7, length(unlist(st_scales)), by=8)]
  df$st8 <- unlist(st_scales)[seq(8, length(unlist(st_scales)), by=8)]
  
  df$t1 <- unlist(t_scales)[seq(1, length(unlist(t_scales)), by=5)]
  df$t2 <- unlist(t_scales)[seq(2, length(unlist(t_scales)), by=5)]
  df$t3 <- unlist(t_scales)[seq(3, length(unlist(t_scales)), by=5)]
  df$t4 <- unlist(t_scales)[seq(4, length(unlist(t_scales)), by=5)]
  df$t5 <- unlist(t_scales)[seq(5, length(unlist(t_scales)), by=5)]
  
  saveRDS(df, paste0("rds/cleaned_",name,".rds"))
}
