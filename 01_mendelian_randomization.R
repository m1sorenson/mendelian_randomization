Sys.setenv("DISPLAY"=":0.0")
#Make sure gmp is updated, see https://gmplib.org/#DOWNLOAD
library(TwoSampleMR)
library(data.table)
library(dplyr)

#-----TODO: change this-----
mr_dir <- "/home/michael/Desktop/mendelian_randomization/"
#---------end TODO----------

#Set up output directory and figure directory
dir.create(file.path(mr_dir, "output"), showWarnings = FALSE)
dir.create(file.path(mr_dir, "output", "figure"), showWarnings = FALSE)

#-----TODO: change this-----
ref_file <- "eur_ptsd_pcs_v3_july12_2021.fuma.gz"
ref_dat <- fread(cmd=paste("zcat ", mr_dir, "reference_data/", ref_file, sep=""), data.table=F)
ref_dat$A1 <- ref_dat$Allele1
ref_dat$A2 <- ref_dat$Allele2
sed=3.09
ref_dat$BETA = ref_dat$Zscore * sed / sqrt(2*ref_dat$Weight*ref_dat$Freq1*(1-ref_dat$Freq1))
ref_dat$SE <- ref_dat$BETA / ref_dat$Zscore
ref_dat$P <- ref_dat[,"P-value"]
ref_dat$samplesize <- 182199 # ref_dat$Neff
ref_dat$phenotype_col <- "ptsd"
ref_dat$SNP <- ref_dat$MarkerName
ref_dat$MAF <- ref_dat$Freq1
#---------end TODO----------


pthresh=5e-8


#NULL #
EAF_col="MAF" #"MAF"  #set to NULL for the psychiatric traits that are missing EAF

#-----TODO: change this-----
# each line should be the name of a file in the data directorry
studies <- scan(what=character())
EAGLE_AD_GWAS_results_2015.txt.gz
HanY_prePMID_asthma_Meta-analysis_UKBB_TAGC.txt.gz
RA_GWASmeta_TransEthnic_v2.txt.gz
#---------end TODO----------

#-----TODO: change this-----
studies_N <- c(247657, 536345, 80799)
studies_pheno <- c("Eczema", "Asthma", "Rheumatoid Arthritis")
#---------end TODO----------

print(studies)

report_predictor <- function(exposurea, outcome, datadir) {
  ## Basic MR steps

  #Filter to just the good SNPs!
  exposure <- exposurea[which(exposurea[,"P"] < pthresh),]

  #Format exposure
  exposure_rf <- format_data(exposure,type="exposure",snp_col="SNP",beta_col="BETA",eaf_col=EAF_col,se_col="SE",effect_allele_col="A1",other_allele_col="A2",pval_col="P",phenotype_col="phenotype_col",samplesize_col="samplesize")

  #Filter exposure to only SNPs in outcome data
  exposure_rf <- subset(exposure_rf,!is.na(other_allele.exposure) & SNP %in% outcome$SNP) #prior to clumping, only take overlapping markers

  #Clump exposure
  exposure_clump <- clump_data(exposure_rf, clump_r2 = 0.001)

  #Filter outcome to only clumped SNPs
  outcome2 <- subset(outcome,SNP %in% exposure_clump$SNP)

  #Format outcome
  outcome_rf <- format_data(outcome2,type="outcome",snp_col="SNP",beta_col="BETA",se_col="SE",eaf_col=EAF_col,effect_allele_col="A1",other_allele_col="A2",pval_col="P",phenotype_col="phenotype_col",samplesize_col="samplesize")

  #harmonize data
  harmdat <- harmonise_data(exposure_clump ,outcome_rf)

  #Produce MR report
  mr_report(harmdat)

  #Move files into output folder
  pheno1 = exposurea["phenotype_col"][0]
  pheno2 = outcome["phenotype_col"][0]
  file.rename(from = paste(mr_dir, "TwoSampleMR.", pheno1, "_against_", pheno2, ".html", sep=""),  to = file.path(mr_dir, "output"))
  file.rename(from = paste(mr_dir, "TwoSampleMR.", pheno2, "_against_", pheno1, ".html", sep=""),  to = file.path(mr_dir, "output"))
  for file in list.files(file.path(mr_dir, "figure")) {
    file.rename(from = file.path(mr_dir, "figure", file), to = file.path(mr_dir, "output", "figure"))
  }


  rm(exposurea)
  rm(outcome)
  rm(datadir)
  rm(exposure)
  rm(exposure_rf)
  rm(exposure_clump)
  rm(outcome2)
  rm(outcome_rf)
  rm(harmdat)
  gc()
}

for (i in 1:3) {
  file <- studies[i]
  diseasedata <- fread(cmd=paste('zcat filled_data/', file, sep=""), data.table=F)
  missing <- FALSE
  if(!"BETA" %in% colnames(diseasedata)) {
    # calculate BETA = ln(OR)
    if("OR" %in% colnames(diseasedata)) {
      diseasedata$BETA=log(diseasedata$OR)
    }
    else if("Z" %in% colnames(diseasedata) && "MAF" %in% colnames(diseasedata)) {
      sed=3.09
      diseasedata$BETA = diseasedata$Z * sed / sqrt(2*studies_N[i]*diseasedata$MAF*(1-diseasedata$MAF))
    }
    else {
      print(paste("BETA not found for: ", file, sep=""))
      print("Skipping...")
      missing <- TRUE
    }
  }
  if(!"SE" %in% colnames(diseasedata)) {
    # calculate SE
  }
  if (!missing) {
    disease <- substring(file, 0, regexpr("\\.", file) - 1)
    print(disease)
    diseasedata$samplesize <- studies_N[i]
    diseasedata$phenotype_col <- studies_pheno[i]

    report_predictor(diseasedata, ref_dat, datadir)
    report_predictor(ref_dat, diseasedata, datadir)
  }
  rm(diseasedata)
  gc()
}
