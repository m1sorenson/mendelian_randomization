#!/bin/bash
./11_fix_file_headers.sh # changes file headers to [SNP, CHR, POS, BETA, MAF, SE, A1, A2, OR, P, phenotype_col, samplesize],
                         # though not necessarily in that order, and not all columns are required

./12_clean_summ_stats.sh # gets rid of SNPs without rsids

./13_fill_missing.sh     # adds minor allele frequency if necessary
