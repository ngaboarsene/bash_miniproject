#!/usr/bin/bash

cd ../Data/ 
grep -c ">" IP-004_S38_L001_scaffolds.fasta > ../results/sequence_count.txt 
