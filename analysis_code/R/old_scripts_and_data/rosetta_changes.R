dat1 <- readRDS("cleaned_dat1.rds")
dat2 <- readRDS("cleaned_dat2.rds")
dat1d <- readRDS("cleaned_dat1d.rds")
dat2d <- readRDS("cleaned_dat2d.rds")

dat_rosetta <- readRDS("cleaned_dat_rosetta.rds")
dat_rosetta7 <- readRDS("cleaned_dat_rosetta7.rds")
dat_rosetta8 <- readRDS("cleaned_dat_rosetta8.rds")
dat_rosetta9 <- readRDS("cleaned_dat_rosetta9.rds")
dat_rosetta10 <- readRDS("cleaned_dat_rosetta10.rds")


dat2$id <- paste0(dat2$res, dat2$pdbid, dat2$chain)
dat_rosetta10$id <- paste0(dat_rosetta10$res, dat_rosetta10$pdbid, dat_rosetta10$chain)

in.common <- unique(intersect(dat_rosetta10$id, dat2$id))

dat2.common <- dat2[which(dat2$id %in% in.common),]
dat2.common <- dat2.common[order(dat2.common$id),]
dat_rosetta10.common <- dat_rosetta10[which(dat_rosetta10$id %in% in.common),]
dat_rosetta10.common <- dat_rosetta10.common[order(dat_rosetta10.common$id),]

par(mfrow=c(2,2))

hist(dat_rosetta10.common$pka - dat2.common$pka, 
     main=paste0("Change in pKa after Rosetta\nmedian = ", 
                 round(median(dat_rosetta10.common$pka - dat2.common$pka),2)),
     xlab="Rosetta 10 pKa - Data v2 pKa",
     breaks=50)

hist(dat_rosetta10.common[which(dat_rosetta10.common$y == 1), "pka"] - 
       dat2.common[which(dat2.common$y == 1), "pka"], 
     main=paste0("Change in pKa after Rosetta (+ samples only)\nmedian = ", 
                 round(median(dat_rosetta10.common[which(dat_rosetta10.common$y == 1), "pka"] - 
                              dat2.common[which(dat2.common$y == 1), "pka"]),2)),
     xlab="Rosetta 10 pKa - Data v2 pKa",
     breaks=50)

hist(dat_rosetta10.common[which(dat_rosetta10.common$y == 0), "pka"] - 
       dat2.common[which(dat2.common$y == 0), "pka"], 
     main=paste0("Change in pKa after Rosetta (- samples only)\nmedian = ", 
                 round(median(dat_rosetta10.common[which(dat_rosetta10.common$y == 0), "pka"] - 
                              dat2.common[which(dat2.common$y == 0), "pka"]),2)),
     xlab="Rosetta 10 pKa - Data v2 pKa",
     breaks=50)

hist(dat_rosetta10$pka - dat_rosetta7$pka, 
     main=paste0("Change in pKa between 7A and 10A cutoff\nmedian = ", 
                 round(median(dat_rosetta10$pka - dat_rosetta7$pka),2)),
     xlab="Rosetta 10 pKa - Rosetta 7 pKa",
     breaks=50)







hist(dat_rosetta10.common$exposure - dat2.common$exposure, 
     main=paste0("Change in exposure after Rosetta\nmedian = ", 
                 round(median(dat_rosetta10.common$exposure - dat2.common$exposure),2)),
     xlab="Rosetta 10 exposure - Data v2 exposure",
     breaks=50)

hist(dat_rosetta10.common[which(dat_rosetta10.common$y == 1), "exposure"] - 
       dat2.common[which(dat2.common$y == 1), "exposure"], 
     main=paste0("Change in exposure after Rosetta (+ samples only)\nmedian = ", 
                 round(median(dat_rosetta10.common[which(dat_rosetta10.common$y == 1), "exposure"] - 
                              dat2.common[which(dat2.common$y == 1), "exposure"]),2)),
     xlab="Rosetta 10 exposure - Data v2 exposure",
     breaks=50)

hist(dat_rosetta10.common[which(dat_rosetta10.common$y == 0), "exposure"] - 
       dat2.common[which(dat2.common$y == 0), "exposure"], 
     main=paste0("Change in exposure after Rosetta (- samples only)\nmedian = ", 
                 round(median(dat_rosetta10.common[which(dat_rosetta10.common$y == 0), "exposure"] - 
                              dat2.common[which(dat2.common$y == 0), "exposure"]),2)),
     xlab="Rosetta 10 exposure - Data v2 exposure",
     breaks=50)

hist(dat_rosetta10$exposure - dat_rosetta7$exposure, 
     main=paste0("Change in exposure between 7A and 10A cutoff\nmedian = ", 
                 round(median(dat_rosetta10$exposure - dat_rosetta7$exposure),2)),
     xlab="Rosetta 10 exposure - Rosetta 7 exposure",
     breaks=50)
