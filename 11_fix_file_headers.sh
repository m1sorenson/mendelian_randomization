#!/bin/bash
mkdir -p tmp
mkdir -p fixed_header
echo -n "" > headers.txt
# Fix headers
for file in $(ls data); do
  echo data/$file
  outfile=${file%.gz}
  zcat data/$file | head -n 1 > tmp/$outfile.header
  zcat data/$file | tail -n+2 > tmp/$outfile.data
  #rm data/$file
  python3 11_fix_header.py tmp/$outfile.header
  cat tmp/$outfile.header.fixed tmp/$outfile.data | gzip -c > fixed_header/$outfile.gz #data/$file
  rm tmp/$outfile.header tmp/$outfile.data tmp/$outfile.header.fixed
  zcat fixed_header/$outfile.gz | head -n 1 >> headers.txt
  echo "" >> headers.txt
done
rm -r tmp
