# Utah Public Health Laboratory (UPHL) Reference-Free Pipeline

### Description
This repository houses the scripts Tiffany Hsu wrote to automate and run the UPHL \
Reference-Free pipeline, which was written by Kelly Oakeson (UPHL) and documented \
[here](https://jcm.asm.org/content/56/11/e00161-18) and [here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5572866/). Erin Young (UPHL) helped confirm which parameters/options were used \
for the different steps.

### Goals
Tiffany Hsu was the APHL-CDC Bioinformatics Fellow placed at the Massachusetts \
Department of Public Health (MDPH) State Laboratory. She created this repository \
so that the UPHL Reference-Free pipeline could be:
1. Pulled onto any Linux computer
2. Reproducibly run at the Massachusetts State Laboratory (or elsewhere)
3. Automated and easy for laboratory staff to run 

# Instructions
## Step 1: Login to your username on the MDPH Linux server. Clone the repository into any location.

Cloning the repository is preferred, but may take up to 30 minutes on the MDPH Linux \
server due to slow internet speeds (the Linux server is on the Bioinformatics Network). \
Until the new Bioinformatic Network is created, a workaround is to download the repository \
on a computer connected to the State Network. To do this:
1. Login to the state computer and go to the gitlab website.
2. Download the repository onto a flash drive.
3. Plug the flash drive into the MDPH Linux server, and move the zipped folder into the \
directory of interest.

Note: If you have already completed the steps above, you may re-use the directory from your \
last run assuming:
1. There are no changes to the UPHL Reference-Free Pipeline (or you do not need to run an \
updated version of the pipeline, AND
2. You have stored data from a previous run somewhere safe.


## Step 2: Create the directories for the pipeline.

Note: This step could possibly be skipped. Tiffany tested this once and it seemed \
to work.

Tiffany connected the tools within the UPHL Reference Free pipeline using the \
tool [SnakeMake](https://snakemake.readthedocs.io/en/stable/). SnakeMake utilizes \
snakefiles to find input and determine where to place output files. The input and \
output directories can be created beforehand in the `uphl_reference_free` folder using \
the command below: 
```
# Run the included script to generate the directories.
$ sh scripts/initiate_dirs.sh 
```

## Step 3: Add samples to the input folder and list them in a text file.

Sequencing files for samples should be inside the folder `uphl_reference_free/BaseCalls`. \
We only need the `fastq.gz` files (from the MiSeq). 

Next, add the names of each sample file (the `*R1_001.fastq.gz` files) to a text file named \
`samples.txt`. Be sure each sample name is written only once! (Specifically, don't put both \
`R1_001.fastq.gz` and `R2_001.fastq.gz` in the text file!)

```
# Move your files (in a folder named "BaseCalls" to the uphl_reference_free folder.
$ mkdir BaseCalls # if not already made
$ cp -r /path/to/files /path/to/uphl_reference_free/BaseCalls

# Create a file with your sample names
## To do this via command line, first get your sample names
## Go into the folder BaseCalls
$ cd BaseCalls
## List your files
$ ls * | grep -v 'R1'
# Copy into a text file as below
```

You can also create your text file using the graphical user interface (CentOS 7). 
1. Go to "Applications" > "Accessories" > "Text Editor"
2. Add the names of all the "R1" files.
3. Save the file as `samples.txt` in the `uphl_reference_free` folder.


## Step 4: Run the pipeline(s)-of-interest.

The UPHL Reference-Free Pipeline is split into 3 pipelines:
1. Main pipeline
2. _Salmonella_ pipeline
3. _E. coli_ pipeline

Each pipeline can be run by invoking Snakemake. Eventually, the goal is to make \
it so that running the _Salmonella_ OR _E. coli_ pipeline automatically invokes \
the main pipeline.

### Running the main pipeline
```
# Make sure you are in the folder "uphl_reference_free" 
# Activate the snakemake environment
$ source activate /home/workflows/miniconda3/envs/snakemake

# Run the pipeline
$ snakemake -j --use-conda
# -j specifies what resources your computer can use to run the pipeline \
# we have up to 32 cores, but if you don't specify the value it will simply use \
all 32
# --use-conda forces the pipeline to install the other tools in your folder
```

### Running the _Salmonella_ pipeline.
This pipeline runs MASH, for checking the genus and species, as well as \
SeqSero (for typing Salmonella) on the cleaned reads (results from SeqyClean).
```
# Activate the snakemake environment
$ source activate /home/workflows/miniconda3/envs/snakemake

# Assuming you are in the "uphl_reference_free" folder, change directory into \
the salmonella folder
$ cd ./salmonella

# Copy over the "samples.txt" files. Samples are still under the "BaseCalls"\
folder.
$ cp ../samples.txt .

# Run the pipeline
$ snakemake -j --use-conda
```
Results will be located in the `uphl_reference_free-master/salmonella/seqsero` \
folder.


### Run the _E. coli_ pipeline.
This pipeline only runs SerotypeFinder and ResFinder on the assembled contigs \
(results from Shovill). It is currently incomplete.
```
# Activate the snakemake environment
$ source activate /home/workflows/miniconda3/envs/snakemake

# Assuming you are in the "uphl_reference_free" folder, change directory into \
the ecoli folder
$ cd ./ecoli

# Copy over the "samples.txt" files. Samples are still under the "BaseCalls"\
folder.
$ cp ../samples.txt .

# Run the pipeline
$ snakemake -j --use-conda
```

Results will be located in the `uphl_reference_free-master/ecoli` folder.


## Step 5: Find the pan-genome.

The main pipeline cleans reads, assembles genomes, and calls genes. In order to compare \
genomes, we need to find the pan-genome, defined as "all of the genes within a \
set of genomes." We will be using the tool [Roary](https://sanger-pathogens.github.io/Roary/) to generate
the pan-genome. 

Roary takes gene calls from your set of genomes, and determine which genes are "core"\
genes (all species have them) as opposed to "dipensable" (specific to certain \
strains or species). We will ue the core genome output from Roary to compare out \
strain set.

```
# 1. Make sure you are in the "uphl_reference_free" directory.
# 2. Identify all of the samples (genomes) you want to compare.
# 3. Copy the genome file formats (gffs) generated by Prokka and place them in \
a single folder. 
$ cd /path/to/uphl_reference_free
$ cp -r /path/to/prokka/*.gff /path/to/to_compare

# 3. Activate the Roary environment.
$ source activate /home/workflows/miniconda3/envs/roary

# 4. Make a directory for results, and run Roary
$ roary -p 32 -f roary -e -n path/to/to_compare/*.gff
# -f specifies the output directory, while -e asks Roary to create a multifasta \
alignment of core genes
```


## Step 6: Create a tree from the core genome alignment.

We will use iqtree, which uses maximum likelihood methods to create a tree.

```
# 1. Make a directory for the results
$ mkdir roary/iqtree 

# 2. Change directory into roary.
$ cd roary

# 2. Run iqtree
$ iqtree -s core_gene_alignment.aln -t RANDOM -m HKY+I+R -bb 1000 \
-pre iqtree/iqtree -nt AUTO
# Note that -pre gives the files a prefix
```


## Step 7: Visualize the tree.

UPHL does this in R using the package Ape. For now, we will do this in:
1. FigTree
2. CLC Genomics Workbench

### FigTree
```
# Start FigTree 
$ java -jar /home/workflows/programs/FigTree_v1.4.3/lib/figtree.jar
# This should launch a user interface for FigTree
```
#### Within the program:
1. Go to: "File" > "Open". Then select your file, which should have the ending \
`*.treefile` (the tree) or `*.contree` (the consensus tree). You usually want the \
former.
2. You can manually annotate your samples if needed. However, if you have many \
samples to annotate, you may want to use "File" > "Import Annotations".

### CLC Genomics Workbench
1. CLC Genomics Workbench cannot see your files unless they are under \
`/home/<YOUR_USERNAME>/CLC_Data`. Move your iqtree files to a folder there.
2. You can then launch "CLC Genomics Workbench" and double click the `*.treefile` \
(the tree) or `*.contree` (the consensus tree) to view them.


## Helpful Tips:
* To check the status of the computer, use the command `htop`. This will show you \
the resources the computer is currently using.
* For now, after running this pipeline the first time, I would:
  * Start from Step 3, adding any new files into the folder `BaseCalls` and sample \
    names into the file `samples.txt`
  * Why is this?
    * If you repeat this from the start each time, you will have to redownload \
      all the programs (shovill, prokka, etc) each time.
    * This would normally not be a problem, but with the current internet speed,\
      will add another 1-2 hours to the pipeline.
