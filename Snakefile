import re

configfile: "config.yaml"

# Get samples
SAMPLES = []
for sample in open( config["samples"], "r" ):
	name = re.sub( "_R[1-9]_001.fastq.gz", "", sample.strip() )
	SAMPLES.append( name )


# Start workflow
rule final:
	input: "multiqc_report.html"


rule fastqc_original:
	input:
		expand(["BaseCalls/{sample}_R1_001.fastq.gz", "BaseCalls/{sample}_R2_001.fastq.gz"], sample=SAMPLES)
	output:
		expand(["fastqc/original/{sample}_R1_001_fastqc.zip", "fastqc/original/{sample}_R2_001_fastqc.zip"], sample=SAMPLES)	
	message:"Running fastqc on original data"
	params:
		FASTQC_ORIG_FOLDER="fastqc/original"
	shell:  "fastqc --outdir {params.FASTQC_ORIG_FOLDER} --threads 32 {input}"


rule seqyclean:
	input:
		R1="BaseCalls/{sample}_R1_001.fastq.gz",
		R2="BaseCalls/{sample}_R2_001.fastq.gz"
	output:
		PE1="seqyclean/{sample}_PE1.fastq",
		PE2="seqyclean/{sample}_PE2.fastq",
		SE="seqyclean/{sample}_SE.fastq",
		STSV="seqyclean/{sample}_SummaryStatistics.tsv",
		STXT="seqyclean/{sample}_SummaryStatistics.txt"
	message: "Running seqyclean."
	params:
		SEQYFOLDER="seqyclean/{sample}"
	shell:
		"/home/workflows/reference_free/seqyclean-master/bin/seqyclean -minlen 25 -qual -1 {input.R1} -2 {input.R2} -o {params.SEQYFOLDER}"


rule fastqc_cleaned:
	input:
		expand(["seqyclean/{sample}_PE1.fastq", "seqyclean/{sample}_PE2.fastq", "seqyclean/{sample}_SE.fastq"], sample=SAMPLES)
	output:
		expand(["fastqc/cleaned/{sample}_PE1_fastqc.zip", "fastqc/cleaned/{sample}_PE2_fastqc.zip", "fastqc/cleaned/{sample}_SE_fastqc.zip"], sample=SAMPLES)
	params:
		FASTQC_CLEANED_FOLDER="fastqc/cleaned"
	shell: "fastqc --outdir {params.FASTQC_CLEANED_FOLDER} --threads 32 {input}"


rule shovill:
	input:
		PE1="seqyclean/{sample}_PE1.fastq",
		PE2="seqyclean/{sample}_PE2.fastq"
	output:
		"shovill/{sample}/contigs.fa",
		"shovill/{sample}/contigs.gfa",
		"shovill/{sample}/shovill.corrections",
		"shovill/{sample}/shovill.log",
		"shovill/{sample}/spades.fasta"
	message:"Running shovill."
	conda:	"envs/shovill.yaml"
	shell:  
		"shovill --cpu 32 --ram 400 --outdir shovill/{wildcards.sample} --R1 {input.PE1} --R2 {input.PE2} --force"

rule quast:
	input:
		"shovill/{sample}/contigs.fa"
	output:
		"quast/{sample}/report.html",
		"quast/{sample}/report.pdf",
		"quast/{sample}/report.tex",
		"quast/{sample}/report.tsv",
		"quast/{sample}/report.txt",
		"quast/{sample}/transposed_report.tex",
		"quast/{sample}/transposed_report.tsv",
		"quast/{sample}/transposed_report.txt",
		"quast/{sample}/quast.log"
	message:"Running quast"
	conda:	"envs/quast.yaml"
	shell:
		"quast shovill/{wildcards.sample}/contigs.fa --output-dir quast/{wildcards.sample}"


rule prokka:
	input:
		"shovill/{sample}/contigs.fa"
	output:
		"prokka/{sample}/{sample}.err",
		"prokka/{sample}/{sample}.faa",
		"prokka/{sample}/{sample}.ffn",
		"prokka/{sample}/{sample}.fna",
		"prokka/{sample}/{sample}.fsa",
		"prokka/{sample}/{sample}.gbk",
		"prokka/{sample}/{sample}.gff",
		"prokka/{sample}/{sample}.log",
		"prokka/{sample}/{sample}.sqn",
		"prokka/{sample}/{sample}.tbl",
		"prokka/{sample}/{sample}.tsv",
		"prokka/{sample}/{sample}.txt"
	message:"Running prokka"
	conda:  "envs/prokka.yaml"
	shell:
		"prokka --cpu 32 --compliant --centre MASPHL --mincontiglen 500 --outdir prokka/{wildcards.sample} --locustag locus_tag --prefix {wildcards.sample} --force shovill/{wildcards.sample}/contigs.fa"


rule multiqc:
	input: 	 expand(["quast/{sample}/report.html", "quast/{sample}/report.pdf", "quast/{sample}/report.tex", "quast/{sample}/report.tsv", "quast/{sample}/report.txt", "quast/{sample}/transposed_report.tex", "quast/{sample}/transposed_report.tsv", "quast/{sample}/transposed_report.txt", "quast/{sample}/quast.log", "fastqc/original/{sample}_R1_001_fastqc.zip", "fastqc/original/{sample}_R2_001_fastqc.zip", "fastqc/cleaned/{sample}_PE1_fastqc.zip", "fastqc/cleaned/{sample}_PE2_fastqc.zip", "fastqc/cleaned/{sample}_SE_fastqc.zip", "prokka/{sample}/{sample}.err"], sample=SAMPLES)
	output: 
		"multiqc_report.html"
	message:"Running multiqc"
	conda:  "envs/multiqc.yaml"
	shell: 
		"multiqc -d -v ./quast ./fastqc ./prokka"
