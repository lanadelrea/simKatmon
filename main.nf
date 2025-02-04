// enable dsl2
nextflow.enable.dsl=2

// import modules

include {ww_simulations}     from './modules/01-ww_simulations.nf'
include {fastq_files}         from './modules/01-ww_simulations.nf'
include {minimap2}           from './modules/02-fastq_to_fasta.nf'
include {samtools_fixmate}   from './modules/02-fastq_to_fasta.nf'
include {samtools_sort}      from './modules/02-fastq_to_fasta.nf'
include {samtools_markdup}   from './modules/02-fastq_to_fasta.nf'
include {samtools_view}      from './modules/02-fastq_to_fasta.nf'
include {samtools_index}     from './modules/02-fastq_to_fasta.nf'
include {samtools_consensus} from './modules/02-fastq_to_fasta.nf'
include {rename_fasta}       from './modules/02-fastq_to_fasta.nf'

workflow {
	main:
	ww_simulations(params.fasta, params.proportions, params.primer_scheme)
	
	fastq_files( params.sample, ww_simulations.out.ch_fastq_file)
	minimap2( params.sample, params.reference, ww_simulations.out.ch_fastq_file )
	samtools_fixmate( minimap2.out.sam )
	samtools_sort( samtools_fixmate.out.fixmatebam)
	samtools_markdup( samtools_sort.out.possrtbam )
	samtools_view( samtools_markdup.out.markdupbam )
	samtools_index( samtools_view.out.finalbam )
	samtools_consensus( samtools_view.out.finalbam )

	rename_fasta( samtools_consensus.out.fasta )
}
