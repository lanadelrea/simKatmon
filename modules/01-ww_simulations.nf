#!/usr/bin/env nextflow

process ww_simulations {
	conda '/home/bdmu/miniforge3/envs/ww_simulations'
	tag "Simulating reads"

	publishDir (
	path: "${params.out_dir}/01-simulated_reads",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	path (fasta)
	path (proportions)
	path (primer_scheme)

	output:
	path ('*.fq'), emit: ch_fastq_file

	script:
	"""
	generate_simulated_datasets.py \
	-f ${fasta} \
	-i ${proportions} \
	-p ${primer_scheme} \
	-n 100000 \
	-r 700
	"""
}

process fastq_files {
	tag "Copying fastq files for Katmon input"

        publishDir (
        path: "${params.out_dir}/03-katmon_input",
        mode: 'copy',
        overwrite: 'true',
        )

	input:
	val (sample)
	tuple path (fq1), path (fq2), path (linA_fq1), path (linA_fq2), path (linB_fq1), path (linB_fq2)

	output:
	path ('*.fastq')

	script:
	"""
	cat ${fq1} ${fq2} > ${sample}.fastq
	"""
}
