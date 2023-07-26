## Introduction

**nf-stem** is a minimal nf-core pipeline containing as few components as possible. The idea is to be as light as possible while maintaining compatibility with nf-core tools such as modules and subworkflows. You could use this as a template to start your own pipeline or explore alternative methods of working with the nf-core template. It is inspired by [kenibrewer/simplenextflow](https://github.com/kenibrewer/simplenextflow) but it has the following differences:

- It is generated using the template and should be compatible with `nf-core sync` for the foreseeable future
- It uses the `nf-validate` plugin to reduce boilerplate code
- It removes some additional files such as `docs/`
- It uses Nextflow code to replace the Java classes in `lib/` (see [the initialise subworkflow](./subworkflows/local/initialise/main.nf))
- It uses `results` as a default value for `--outdir` to remove one additional parameter user need to supply
- It removes email and slack integration for simplicity
- It removes Github features so developers can add their own

You probably shouldn't use this, it's a good POC for how simple nf-core could be in future. If you think you can simplify it, open a PR!

### Potential simplifications:

- Remove, move or reduce editor files to make the repo look less messy
- Combine documentation into fewer files to reduce documentation overhead
- Simplify the contents of the Nextflow code itself

I have adapted Ken Brewer's instructions for cloning his template below but updated them for this repo:

## Template instructions:

### Make your own repo

- [ ] Fork the repo to your own organisation and change the name to something appropriate

### Template Naming

- [ ] Replace all instances of `nf-stem` with the name of your pipeline
- [ ] Replace all instances of `adamrtalbot` with your GitHub username/organization

### Samplesheet handling

- [ ] Update the `assets/schema_input.json` for your own samplesheet. Use the [nf-validate documentation](https://nextflow-io.github.io/nf-validation/nextflow_schema/sample_sheet_schema_specification/) to guide you.

### Add needed modules/processes

- [ ] Add any needed nf-core modules via the cli command `nf-core modules install`
- [ ] Add any custom processes to the `modules/local` directory
- [ ] Add and required software to the `environment.yml` file to be installed via conda or wave containers

### Modify the main workflow

- [ ] Modify the `main.nf` file to add any needed processes

### Documentation

- [ ] Search for `TODO` and replace with your own content
- [ ] Delete this section of the README

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
```

Now, you can run the pipeline using:

```bash
nextflow run adamrtalbot/nfstem \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv
```

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

adamrtalbot/nfstem was originally written by Adam Talbot.

We thank the following people for their extensive assistance in the development of this pipeline:

- Ken Brewer (@kenibrewer)

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
