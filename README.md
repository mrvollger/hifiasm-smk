# hifiasm-smk

## Install

Please start by installing [pixi](https://pixi.sh/latest/) which handles the environment of this Snakemake workflow.

You can then install the `pixi` environment by cloning this repository and running:

```bash
pixi install
```

## Test case

Before running the workflow please run the test case to make sure everything is working as expected.

```bash
pixi run test
```

## Usage

`pixi` handles the execution of the Snakemake workflows:

```bash
pixi run snakemake --configfile ...
```

And if you want to run this Snakemake from another directory you can do so with:

```bash
pixi run --manifest-path /path/to/snakemake/pixi.toml snakemake ...
```

where you update `/path/to/snakemake/pixi.toml` to the path of the `pixi.toml` you cloned.

And in place of `...` use all the normal Snakemake arguments for your workflow.

## Configuration

Your configuration file (e.g. `config.yaml`) should have a manifest entry that points to the inputs to be assembled. For example:

```yaml
manifest: test/test.tbl
```

The manifest file should be a space-separated file of the following format:

```
sample hifi paternal maternal
GM12878 /path/to/hifi_reads.fastq.gz /path/to/paternal_reads.fastq.gz /path/to/maternal_reads.fastq.gz
```

The inputs need not be in fastq format: bam, sam, cram, and fasta are also supported. The workflow will automatically detect the file type and run the appropriate tools.

If you don't have paternal or maternal data you can replace the paths with "NA". For example:

```
sample hifi paternal maternal
GM12878 /path/to/hifi_reads.fastq.gz NA NA
```

You can also add as many samples as you want. The workflow will run for all the samples in the manifest.

### Submitting to the Hyak HPC via Slurm

```bash
pixi run snakemake --configfile /path/to/your/config.yaml --profile profiles/slurm-executor
```
