#!/usr/bin/env nextflow

process ww_simulations {
	cpus 1
	tag "Simulating reads"

	publishDir (
	path: "${params.out_dir}/01-simulated_reads",
	mode: 'copy',
	overwrite: 'true',
	)

	input:
	reference
	proportions
	primer_scheme

	output:
	path ('*.fq')

	script:
	"""
	python generate_simulated_datasets.py \
	-f ${reference} \
	-i ${proportions} \
	-p ${primer_scheme} \
	-n 100000 \
	-r 700
	"""
}
