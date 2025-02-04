#!/usr/bin/env nextflow

process minimap2 {
	container 'nanozoo/minimap2:latest'
	tag "Aligning reads to the reference"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	val (sample)
	path (reference)
	tuple path (fq1), path (fq2), path (linA_fq1), path (linA_fq2), path (linB_fq1), path (linB_fq2) 

	output:
	tuple val (sample), path ("*.sam"), emit: sam

	script:
	"""
	minimap2 -t 8 -a -x sr ${reference} ${fq1} ${fq2} -o ${sample}.sam
	"""
}

process samtools_fixmate {
	container 'staphb/samtools:latest'
	tag "Making fixmate bam"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val (sample), path (sam)

	output:
	tuple val (sample), path ("*.fixmate.bam"), emit: fixmatebam

	script:
	"""
	samtools fixmate -O bam,level=1 ${sam} ${sample}.fixmate.bam
	"""
}

process samtools_sort {
	container 'staphb/samtools:latest'
	tag "Sorting reads"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val (sample), path (fixmatebam)

	output:
	tuple val (sample), path ("*.pos.srt.bam"), emit: possrtbam

	script:
	"""
	samtools sort -l 1 -@8 -o ${sample}.pos.srt.bam -T /tmp/${sample} ${fixmatebam}
	"""
}

process samtools_markdup {
	container 'staphb/samtools:latest'
	tag "Marking duplicates"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val (sample), path (possrtbam)

	output:
	tuple val (sample), path ("*.markdup.bam"), emit: markdupbam

	script:
	"""
	samtools markdup -O bam,level=1 ${possrtbam} ${sample}.markdup.bam
	"""
}

process samtools_view {
	container 'staphb/samtools:latest'
	tag "Creating final bam"

	publishDir (
	path: "${params.out_dir}/03-katmon_input",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val (sample), path (markdupbam)

	output:
	tuple val (sample), path ("*.bam"), emit: finalbam

	script:
	"""
	samtools view -@8 ${markdupbam} -o ${sample}.bam
	"""
}

process samtools_index {
	container 'staphb/samtools:latest'
	tag "Indexing bam file"

	publishDir(
	path: "${params.out_dir}/03-katmon_input",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val (sample), path (finalbam)

	output:
	path ("*.bai"), emit: bai

	script:
	"""
	samtools index ${finalbam}
	"""
}

process samtools_consensus {
	container 'staphb/samtools:latest'
	tag "Creating consensus sequence"

	input:
	tuple val (sample), path (finalbam)

	output:
	tuple val (sample), path ("*.fasta"), emit: fasta

	script:
	"""
	samtools consensus -f fasta ${finalbam} -o ${sample}.fasta
	"""
}

process rename_fasta {
	container 'nanozoo/seqkit:latest'
	tag "Renaming consensus fasta sequence"

	publishDir (
	path: "${params.out_dir}/03-katmon_input",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val (sample), path (fasta)

	output:
	path ("*.fasta")

	script:
	"""
	cat ${fasta} | seqkit replace -p MN908947.3 -r ${sample} > ${sample}.fasta
	"""
}
