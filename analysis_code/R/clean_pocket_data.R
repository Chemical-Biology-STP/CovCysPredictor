setwd("~/cyscov/R")

fpocket_results <- list()

# Parsing the fpocket results into a list of contained cysteines
for (folder in c("fpocket", "CovBinder_fpocket")) {
  for (qkprep in c("qkprep", "noqkprep")) {
    tmp <- c()
    for (i in c("1","2","3","4","5")) {
      tmp_df <- read.delim(
        paste0("../data/", folder, "/fpocket", i, "_SCYS_", qkprep, "_results.txt"),
                 header=F, sep="")
      colnames(tmp_df) <- c(
        "filename_long", "entry", "sulfur", "cys", "chain", "pos",
        "x","y","z","ignore","ignore2","ignore3","ignore4"
      )
      
      tmp_df$pdbid <- substr(tmp_df$filename_long, 0, 4)
      tmp_df$pdbid_chain_res <- paste0(
        tmp_df$pdbid, "_", 
        tmp_df$chain, "_CYS", 
        tmp_df$pos)
      tmp <- union(
        tmp,
        tmp_df$pdbid_chain_res
      )
    }
    all_chain_results[[paste0(folder,"_",qkprep,"_top5")]] <- tmp
    
    tmp_df <- read.delim(
      paste0("../data/", folder, "/fpocket_any_SCYS_", qkprep,"_results.txt"),
      header=F, sep="")
    colnames(tmp_df) <- c(
      "filename_long", "entry", "sulfur", "cys", "chain", "pos",
      "x","y","z","ignore","ignore2","ignore3","ignore4"
    )
    
    tmp_df$pdbid <- substr(tmp_df$filename_long, 0, 4)
    tmp_df$pdbid_chain_res <- paste0(
      tmp_df$pdbid, "_", 
      tmp_df$chain, "_CYS", 
      tmp_df$pos)
    all_chain_results[[paste0(folder,"_",qkprep,"_any")]] <- tmp_df$pdbid_chain_res
  }
}

#saveRDS(fpocket_results, "rds/fpocket.rds")

get_pdbid_chain_res <- function(df, pdbid, plb_cutoff=NA) {
  if (!is.na(plb_cutoff)) {
    df = df[which(df$PLB >= plb_cutoff),]
  }
  
  chain_splits <- strsplit(df$Residues, ")")
  tmp_cys_store <- c()
  for (site in chain_splits) {
    for (chain in site) {
      if (grepl("CYS", chain)) {
        single_chain_split <- strsplit(chain, " |:\\(")[[1]]
        chain_id <- single_chain_split[1]
        cysteines <- single_chain_split[grepl("CYS", single_chain_split)]
        tmp_cys_store <- union(tmp_cys_store,
                               paste0(pdbid, "_", chain_id, "_", cysteines))
      }
    }
  }
  return(tmp_cys_store)
}

sitefinder_results = list()
# now to parse the sitefinder data
for (folder in c("sitefinder", "CovBinder_sitefinder")) {
  for (qkprep in c("receptor_qkprep_sites", "receptor_sites")) {
    files <- list.files(paste0("../data/", folder), 
               pattern=qkprep)
    tmp_all <- c()
    tmp_plb_0 <- c()
    tmp_plb_1 <- c()
    for (file in files) {
      tmp_df <- read.delim(
        paste0("../data/", folder, "/", file),
        header=T, sep="\t")
      if(any(grepl("CYS", tmp_df$Residues))) {
        tmp_df_cys = tmp_df[grepl("CYS", tmp_df$Residues),]
        pdb_id <- substr(file, 0, 4)
        
        tmp_all <- union(tmp_all, get_pdbid_chain_res(tmp_df_cys, pdb_id, plb_cutoff=NA))
        tmp_plb_0 <- union(tmp_plb_0, get_pdbid_chain_res(tmp_df_cys, pdb_id, plb_cutoff=0))
        tmp_plb_1 <- union(tmp_plb_1, get_pdbid_chain_res(tmp_df_cys, pdb_id, plb_cutoff=1))
      }
    }
    sitefinder_results[[paste0(folder, "_", qkprep, "_any")]] <- tmp_all
    sitefinder_results[[paste0(folder, "_", qkprep, "_plb_0")]] <- tmp_plb_0
    sitefinder_results[[paste0(folder, "_", qkprep, "_plb_1")]] <- tmp_plb_1
  }
}

#saveRDS(sitefinder_results, "rds/sitefinder.rds")
