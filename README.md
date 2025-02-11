- Determine lineages to simulate (eg. AY.75 and BA.2.5)
- Edit proportions tsv file (assets/proportions.tsv)
- Run the pipeline to generate simulated reads (FASTQ) and create other Katmon input files (BAM and FASTA)
  

```nextflow run simKatmon --sample <sample name including proportions> --fasta <fasta file of lineages to simulate> --out_dir <results dir>```

example:

```nextflow run simKatmon --sample AY.75_50_BA.2.5_50 --fasta /assets/AY.75_and_BA.2.5.fasta --out_dir /simulations/AY.75_and_BA.2.5/50_50```
