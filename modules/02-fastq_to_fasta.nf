#!/usr/bin/env nextflow

process minimap2 {
	cpus 1
	container 'nanozoo/minimap2'
	tag "Aligning reads to the reference"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path fastq_1, path fastq_2

	output:
	tuple val sample, path ("*.sam"), emit: sam

	script:
	"""
	minimap2 \ 
	-t 8 \
	-a -x sr \
	${reference} \
	${fastq_1} \
	${fastq_2} \
	-o ${sample}.sam
	"""
}

process samtools_fixmate {
	cpus 1
	container 'staphb/samtools'
	tag "Making fixmate bam"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path sam

	output:
	tuple val sample, path ("*.fixmate.bam"), emit: fixmatebam

	script:
	"""
	samtools fixmate -O bam, level=1 ${sam} ${sample}.fixmate.bam
	"""
}

process samtools_sort {
	cpus 1
	container 'staphb/samtools'
	tag "Sorting reads"

	publishDir (
	path: "${params.out_dir}/02-mapsam",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path fixmatebam

	output:
	tuple val sample, path ("*.pos.srt.bam")

	script:
	"""
	samtools sort -l 1 -@8 -o ${sample}.pos.srt.bam -T /tmp/${sample} ${fixmatebam}
	"""
}

process samtools_markdup {
	cpus 1
	container 'staphb/samtools'
	tag "Marking duplicates"

	publishDir (
	path: "${params.out_dir/02-mapsam}",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path possrtbam

	output:
	tuple val sample, path ("*.markdup.bam"), emit: markdupbam

	script:
	"""
	samtools markdup -O bam,level=1 ${possrtbam} ${sample}.markdup.bam
	"""
}

process samtools_view {
	cpus 1
	container 'staphb/samtools'
	tag "Creating final bam"

	publishDir (
	path: "${params.out_dir/03-katmon_input}",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path markdupbam

	output:
	tuple val sample, path ("*.bam"), emit: bam

	script:
	"""
	samtools view -@8 ${markdupbam} -o ${sample}.bam
	"""
}

process samtools_index {
	cpus 1
	container 'staphb/samtools'
	tag "Indexing bam file"

	publishDir(
	path: "${params.out_dir}/03-katmon_input",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path bam

	output:
	path ("*.bai")

	script:
	"""
	samtools index ${bam}
	"""
}

process samtools_consensus {
	cpus 1
	container 'staphb/samtools'
	tag "Creating consensus sequence"

	publishDir (
	path: "${params.out_dir}/03-katmon_input",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	tuple val sample, path bam

	output:
	tuple val sample, path ("*.fasta")

	script:
	"""
	samtools consensus -f fasta ${bam} -o ${sample}.fasta
	"""
}
