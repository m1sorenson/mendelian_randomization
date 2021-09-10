## About
This repo works as a sort of wrapper for Two Sample Mendelian Randomization, using the [TwoSampleMR](https://github.com/MRCIEU/TwoSampleMR) R package. It also contains code to clean the headers of files and remove SNPs without valid IDs, and merge the MAF from 1000 genomes European frequencies.

## Usage
1. Create a `data` folder and a `reference_data` folder. The `reference_data` will have the trait you are running Mendelian randomization against, and the `data` folder will have all the traits to run against the reference trait.
2. Move/copy gzipped summary stats into the `data` folder and the `reference_data` folder.
3. Run `./00_clean_data.sh`. This does a couple of things:
    1. First, it changes the names of the headers to match the expected headers in the R script
        - Note that A1 should be the effect allele and A2 should be the reference allele. Pay attention to the output printed to console (the script prints the header before making any changes and then prints again for each change)
    2. Next, it removes any rows that contain SNPs without RS ids
    3. Finally, it merges MAF from 1000 genomes SNP frequencies (in Europeans) if necessary
4. Edit all sections of 01_mendelian_randomization.R labeled `#-----TODO: change this-----`

## Troubleshooting
- If there are issues in the R script, check that the final `filled_data` files have all the necessary columns. At a minimum, it must have "SNP", "BETA", "MAF", "SE", "A1", "A2", "P". Note that if "BETA" is missing, the program will automatically try to calculate it from the "OR" column, or both the "Z" and "MAF" columns (so one of those combinations of columns must be there if BETA is not). Additionally, SE can be calculated from the P value column
- Make sure all TODO sections in the R script are fixed, especially check the reference file name, directory, and column names
