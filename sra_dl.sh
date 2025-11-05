#!/bin/bash

# --------------------------------------------------------------
# Script for using SraTools (prefetch and fasterq-dump) in a SRA
# accesion list
# AUTHOR: Alvaro Gutiérrez Morocho
# DATE: 04/10/2025
# --------------------------------------------------------------

## HELP
help_info(){
echo "
                                                                             
  ▄▄▄▄  ▄▄▄▄▄    ▄▄          ▄▄▄▄▄▄   ▄▄    ▄▄▄▄ ▄     ▄        ▄▄▄▄   ▄     
 █▀   ▀ █   ▀█   ██          █        ██   █▀   ▀ ▀▄ ▄▀         █   ▀▄ █     
 ▀█▄▄▄  █▄▄▄▄▀  █  █         █▄▄▄▄▄  █  █  ▀█▄▄▄   ▀█▀          █    █ █     
     ▀█ █   ▀▄  █▄▄█         █       █▄▄█      ▀█   █           █    █ █     
 ▀▄▄▄█▀ █    ▀ █    █        █▄▄▄▄▄ █    █ ▀▄▄▄█▀   █           █▄▄▄▀  █▄▄▄▄▄
                                                                             
                                                                             
                                                                                     	
											"

	echo "Script Description:
---------------------------------------------------------------------
This script downloads batchs of SRA files (Sequence Read Archive) by reading a CSV 
file that contains the accession numbers of the desired files."

	echo ""
	echo "	Usage:	$0 -f <accesion_list_path> -o <output_dir_path> -h"
	echo "	Options:"
	echo "		-f 	SRA accesion list in .csv format"
	echo "		-o	Output directory where the data is downloaded"
	echo "		-h	Shows this help info"
	echo ""
	exit 0
}

## OPTION CONFIGURATION
while getopts "f:o:h" opt; do
	case ${opt} in
	f)
		SRA_LIST="${OPTARG}";;
	o)
		OUTPUT_DIR="${OPTARG}";;
	h)
		help_info;;
	\?)
		echo "ERROR: Option not possible ${OPTARG}" >&2
		help_info
		exit 1;;
	:)
                echo "ERROR: The option -${OPTARG} requires an argument" >&2
                help_info
                exit 1;;
	esac
done

# Exception with no arguments
if [[ "$#" -eq 0 || "$#" -eq 1 ]]; then
    echo "ERROR: Need at least 2 arguments, -f and -o" >&2
    # Llamamos a la función de ayuda para mostrar el uso correcto
    help_info
    exit 1
fi

# OUTPUT_DIR is created if it isn't present in the directory
if [ ! -d $OUTPUT_DIR ]; then
	mkdir -p "${OUTPUT_DIR}"
fi

## USING PREFETCH 

# Confirm that SRA_LIST and OUTPUT_DIR exist respectively
if [ -n $SRA_LIST ] && [ -n $OUTPUT_DIR ]; then
	nohup prefetch --option-file "${SRA_LIST}" --output-directory "${OUTPUT_DIR}" >${OUTPUT_DIR}/prefetch_report.txt
fi

## USING FASTERQ-DUMP FOR .fastq files

# 1. Iterate with each of the directories created by prefetch
for SRA_DIR in "$OUTPUT_DIR"{S,E}*; do
	
	# The files must be directories
	if [ -d $SRA_DIR ]; then
		(
		# Extract the sra_id
		SRA_ID=$(basename "$SRA_DIR")
		echo "Processing sample with accesion number: $SRA_ID"
		
		#Change into the sample directory
		cd "${SRA_DIR}"
		
		# Using fasterq-dump inside the subdirectory
		nohup fasterq-dump "$SRA_ID" --split-files --outdir ./ --threads 8  

		# Getting back to the OUTPU_DIR for the next file
		echo "DEBUG: contenido sra_dir $SRA_DIR y output_dir $OUTPUT_DIR"
		cd ..
		)
	fi
done


