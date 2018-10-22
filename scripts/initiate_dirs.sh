#!/usr/bin/bash

# Use this script to generate the directories needed to run Snakemake.

# For the main pipeline
mkdir -p seqyclean
mkdir -p shovill
mkdir -p quast
mkdir -p fastqc/cleaned
mkdir -p fastqc/original
mkdir -p prokka

# For salmonella samples
mkdir -p salmonella/mash
mkdir -p salmonella/seqsero

# For ecoli samples
mkdir -p ecoli
