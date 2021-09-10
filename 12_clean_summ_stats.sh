#!/bin/bash
mkdir -p tmp
mkdir -p cleaned_data
for file in $(ls fixed_header); do
  echo fixed_header/$file
  outfile=${file%.gz}
  zcat fixed_header/$file | head -n 1 > tmp/$outfile.header
  zcat fixed_header/$file | tail -n+2 > tmp/$outfile.data
  id_col=$(awk '{for(i=1; i<=NF; i++){if($i == "SNP"){print i}}}' tmp/$outfile.header)
  badids=$(awk -v id_col=$id_col '$id_col !~ /[rR][sS]/' tmp/$outfile.data | wc -l)
  goodids=$(awk -v id_col=$id_col '$id_col ~ /[rR][sS]/' tmp/$outfile.data | wc -l)
  echo "Found ${badids} bad ids, ${goodids} good ids"
  awk -v id_col=$id_col '$id_col ~ /[rR][sS]/' tmp/$outfile.data | cat tmp/$outfile.header - | \
    gzip -c > cleaned_data/$file
  rm tmp/$outfile.header tmp/$outfile.data
done
rm -r tmp
rm -r fixed_header
