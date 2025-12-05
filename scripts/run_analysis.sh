#!/usr/bin/bash


if [ $# -eq 0 ]; then # checking if atleast one argument was passed
	echo "Error: No directory provided"
	echo "Syntax: ./analysis.sh /PATH/TO/DIRECTORY"
	exit 1
fi


data_directory="$1"


if [ ! -d "$data_directory" ]; then
	echo "Error: Not a valid directory"
	exit 1
fi


cd $data_directory


required_files=("IP-004_S38_L001_scaffolds.fasta" "humchrx.txt") 
missing_files=() 

for file in "${required_files[@]}"; do 
	[ ! -f "$data_directory/$file" ] && missing_file+=("$file") 
done

if [ ${#missing_file[@]} -gt 0 ]; then  
	echo "Error: Missing file: ${missing_file[*]}"
	exit 1
fi

mkdir ../results
echo "results directory created..."

grep -c ">" IP-004_S38_L001_scaffolds.fasta > ../results/sequence_count.txt
sequence_count=$(grep -c ">" IP-004_S38_L001_scaffolds.fasta)
echo "Counting number of sequences in the FASTA file: DONE..."
echo "There are $sequence_count sequences in the FASTA file"


grep ">" IP-004_S38_L001_scaffolds.fasta | cut -d'>' -f2 | cut -d'_' -f1,2 > ../results/sequence_ids.txt 
id_number=$(grep ">" IP-004_S38_L001_scaffolds.fasta | cut -d'>' -f2 | cut -d'_' -f1,2 | wc -l)
echo "Extracted $id_number  sequence identifiers"
echo "Extracting sequence identifiers from the FASTA file: DONE..."


longest_sequence=$(grep ">" IP-004_S38_L001_scaffolds.fasta | cut -d'_' -f4 | sort -n | tail -1) 

seq_length=$(grep "length_$longest_sequence" IP-004_S38_L001_scaffolds.fasta | cut -d'>' -f2 | cut -d'_' -f4) 
coverage=$(grep "length_$longest_sequence" IP-004_S38_L001_scaffolds.fasta | cut -d'>' -f2 | cut -d'_' -f6) 
sequence_id=$(grep "length_$longest_sequence" IP-004_S38_L001_scaffolds.fasta | cut -d'>' -f2 | cut -d'_' -f1,2) 

touch ../results/longest_sequence.txt # Creating the output file
echo "Longest sequence: $sequence_id" > ../results/longest_sequence.txt
echo "Length: $seq_length" >> ../results/longest_sequence.txt
echo "coverage: $coverage" >> ../results/longest_sequence.txt
echo "Finding the longest sequence in the FASTA file: DONE..."


echo "Starting sequence filtering and statistics"
minimum_length=5000 

length_list=$(grep ">" IP-004_S38_L001_scaffolds.fasta | cut -d'_' -f4) 


for length in $length_list; do
        if [ "$length" -ge "$minimum_length" ]; then
                grep "length_$length" IP-004_S38_L001_scaffolds.fasta >> ../results/filtered_sequences.txt
        fi
done
echo "Filtering of sequences by minimum length of 5000: DONE..."
 
e number of generated sequences
sequence_count2=$(cat ../results/filtered_sequences.txt | wc -l)

echo "Found $sequence_count2 sequences with >= $minimum_length bases"


minimum_length2=10000
minimum_coverage=5.0


length_list=$(grep ">" IP-004_S38_L001_scaffolds.fasta | cut -d'_' -f4) 

for length in $length_list; do 
        if [ "$length" -ge "$minimum_length2" ]; then 
                cov=$(grep "length_$length" IP-004_S38_L001_scaffolds.fasta | cut -d'_' -f6)
                if [ -n "$cov" ] && [ $(echo "$cov >= $minimum_coverage" | bc -l) -eq 1 ]; then
                        grep "length_$length" IP-004_S38_L001_scaffolds.fasta >> ../results/high_quality_scaffolds.txt
                fi

        fi
done

sequence_count3=$(cat ../results/high_quality_scaffolds.txt | wc -l)
echo "Selecting high quality scaffold sequences based on length and coverage: DONE..."
echo "Found $sequence_count3 sequences high quality scaffolds"

entry_count1=$(cat humchrx.txt | cut -d' ' -f1 | tail -898 | head -890 |wc -l)
echo "Counting protein entries from the database: DONE..."
echo "There are $entry_count1 protein entries" > ../results/protein_count.txt


cat humchrx.txt | cut -d' ' -f1 | tail -898 | head -890 |sort -u > ../results/gene_names_sorted.txt 
echo "Extracting genes from the database: DONE..."

cat humchrx.txt | grep -i "kinase" | cut -c33-45,63- > ../results/protein_search_results.txt 
echo "Searching for kinase proteins among the entries: DONE..."
entry_count2=$(cat humchrx.txt | grep -i "kinase" | cut -c33-45,63- | wc -l)

echo "There are $entry_count2 kinase hits"


touch ../results/analysis_summary.txt
echo "The total number of sequences in the FASTA file is: $sequence_count" > ../results/analysis_summary.txt
echo "The number of high quality scaffolds among the sequences is: $sequence_count3" >> ../results/analysis_summary.txt
echo "The number of protein entries in the database is: $entry_count1" >> ../results/analysis_summary.txt
date >> ../results/analysis_summary.txt

echo "DONE"
