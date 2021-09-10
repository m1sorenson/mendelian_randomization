#!/bin/bash
mkdir -p tmp
mkdir -p filled_data
for file in $(ls cleaned_data); do
  echo cleaned_data/$file
  head=$(zcat cleaned_data/$file | head -n 1)
  hasBETA=$(echo $head | grep "BETA" | wc -l)
  hasOR=$(echo $head | grep "OR" | wc -l)
  hasZ=$(echo $head | grep "Z" | wc -l)
  hasMAF=$(echo $head | grep "MAF" | wc -l)
  id_col=$(echo $head | awk '{for(i=1; i<=NF; i++){if($i == "SNP"){print i}}}')
  chr_col=$(echo $head | awk '{for(i=1; i<=NF; i++){if($i == "CHR"){print i}}}')
  pos_col=$(echo $head | awk '{for(i=1; i<=NF; i++){if($i == "POS"){print i}}}')
  # Check for necessary columns used as BETA value
  if [[ $hasBETA -eq 1 ]] || [[ $hasOR -eq 1 ]]; then
    echo "Has BETA or OR, sorting and saving to filled_data/$file..."
    zcat cleaned_data/$file | LC_ALL=C sort -k${chr_col},${chr_col}nb -k${pos_col},${pos_col}nb | gzip -c > filled_data/$file
  elif [[ $hasZ -eq 1 ]]; then
    if [[ $hasMAF -eq 1 ]]; then
      echo "Has Z and MAF, sorting and saving to filled_data/$file..."
      zcat cleaned_data/$file | LC_ALL=C sort -k${chr_col},${chr_col}nb -k${pos_col},${pos_col}nb | gzip -c > filled_data/$file
    else
      echo "Has Z, but no MAF, merging MAF from 1kg reference, sorting and saving to filled_data/$file..."
      # do something here to get MAF
      zcat cleaned_data/$file | head -n 1 > tmp/header.txt
      zcat cleaned_data/$file | tail -n+2 | LC_ALL=C sort -h -k$id_col | cat tmp/header.txt - | gzip -c \
        > tmp/$file
      zcat tmp/$file | LC_ALL=C join -1 $id_col -2 1 - snp_freqs/snp_freqs_all.sorted.tsv | LC_ALL=C sort -k${chr_col},${chr_col}nb -k${pos_col},${pos_col}nb | gzip -c > filled_data/$file
    fi
  else
    echo "ERROR: File does not have necessary columns to use for BETA: $file" 1>&2
  fi
done
rm -r tmp
rm -r cleaned_data
