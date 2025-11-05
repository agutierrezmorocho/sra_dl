# sra_dl - Description
This script downloads batchs of SRA files (Sequence Read Archive) by reading a CSV 
file that contains the accession numbers of the desired files.

# Usage
This script is very simple, only needing a listo of the required accesion numbers ina .csv format. Then an output directory will be needed for downloading all the files. The script uses the SRATools package from the NCBI. The prefetch tool will be used for downloading the .sra files from the NCBI, and then fasterq-dump will obtain the .fastq files from the accesion numbers given. 

Usage:	$0 -f <accesion_list_path> -o <output_dir_path> -h

Options:

  -f 	SRA accesion list in .csv format
  
  -o	Output directory where the data is downloaded
  
  -h	Shows this help info
