# hifiasm-smk

## Install

Please start by installing [pixi](https://pixi.sh/latest/) which handles the environment of this Snakemake workflow.

You can then install the `pixi` environment by cloning this repository and running:

```bash
pixi install
```

## Usage

`pixi` handles the execution of the Snakemake workflows:

```bash
pixi run snakemake ...
```

And if you want to run this Snakemake from another directory you can do so with:

```bash
pixi run --manifest-path /path/to/snakemake/pixi.toml snakemake ...
```

where you update `/path/to/snakemake/pixi.toml` to the path of the `pixi.toml` you cloned.

And in place of `...` use all the normal Snakemake arguments for your workflow.

## Test case

```bash
pixi run test
```

## Configuration

See `test/test.yaml` and `test/test.tbl` for the configuration files used in the test case. Make you own configuration files and run the workflow with:

```bash
pixi run snakemake --configfile /path/to/your/config.yaml
```
