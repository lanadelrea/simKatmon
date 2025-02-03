- Determine lineages to simulate (eg. AY.122 and BA.1.10)
- Edit proportions tsv file (assets/sim_proportions.tsv)
- Run the pipeline to generate simulated reads (FASTQ) and create other Katmon input files (BAM and FASTA)
  

```nextflow run simKatmon --sample <sample name including proportions> --fasta <fasta file of lineages to simulate> --out_dir <results dir>```

example:

```nextflow run simKatmon --sample AY.122_50_BA.1.10_50 --fasta /assets/AY.122_and_BA.1.10.fasta --out_dir /simulations/AY.122_and_BA.1.10/50_50```
