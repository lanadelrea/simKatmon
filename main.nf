// enable dsl2
nextflow.enable.dsl=2

// import modules

include {ww_simulations}     from './modules/01-ww_simulations.nf'
include {minimap2}           from './modules/02-fastq_to_fasta.nf'
include {samtools_fixmate}   from './modules/02-fastq_to_fasta.nf'
include {samtools_sort}      from './modules/02-fastq_to_fasta.nf'
include {samtools_markdup}   from './modules/02-fastq_to_fasta.nf'
include {samtools_view}      from './modules/02-fastq_to_fasta.nf'
include {samtools_index}     from './modules/02-fastq_to_fasta.nf'
include {samtools_consensus} from './modules/02-fastq_to_fasta.nf'


workflow {
	main:
	ww_simulations(params.reference, params.proportions, params.primer_scheme)
	ch_fastq_file = Channel
			.fromFilePairs("${params.out_dir}/01-simulated_reads/**out{1,2}.fq")
			.filter { it -> 
				!it[0].contains("nCoV-2019art") && !it[1].contains("nCoV-2019art")}
	minimap2( ch_fastq_file )
	samtools_fixmate( minimap2.out.sam )
	samtools_sort( samtools_fixmate.out.fixmatebam)
	samtools_markdup( samtools_sort.out.possrtbam )
	samtools_view( samtools_markdup.out.markdupbam )
	samtools_index( samtools_view.out.finalbam )
	samtools_consensus( samtools_view.out.finalbam )
}
