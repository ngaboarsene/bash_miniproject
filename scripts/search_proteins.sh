#!/usr/bin/bash

cd ../Data/

search_word=$1

cat humchrx.txt | grep -i "$search_word" | cut -c33-45,63- > ../results/protein_search_results.txt 

entry_count=$(cat humchrx.txt | grep -i "$search_word" | cut -c33-45,63- | wc -l) 

echo "There are $entry_count hits"
