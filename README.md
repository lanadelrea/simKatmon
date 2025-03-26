- Determine lineages to simulate (eg. AY.132_and_AY.63)
- Edit proportions tsv file (assets/proportions.tsv)
  example:
  ```
  AY.132 50
  AY.63 50
  ```
- Run the pipeline to generate simulated reads (FASTQ) and create other Katmon input files (BAM and FASTA)

  ```
  nextflow run simKatmon \
  --sample <sample name including proportions> \
  --fasta <fasta file of lineages to simulate> \
  --out_dir <results dir>
  ```

example:

  ```
  nextflow run simKatmon \
  --sample AY.75_50_BA.2.5_50 \
  --fasta /assets/lineages-ref-fasta/AY.132_and_AY.63.fasta \
  --out_dir /simulated-reads/AY.132_and_AY.63/proportion_50_50
  ```

The file size of the simulated reads is too large to be uploaded on GitHub. We have made them available in this [drive](https://drive.google.com/drive/folders/1hU8dP_kKEYtdGeQl5QF8AXQXDVZC2ll-?usp=sharing) for your reference.
