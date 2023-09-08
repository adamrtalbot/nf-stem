#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-stem
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/adamrtalbot/nf-stem
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2


include { validateParameters; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES AND SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

 include { INITIALISE                       } from './subworkflows/local/initialise'
 include { TRIM                             } from './workflows/main'
 include { FQ_LINT                          } from './modules/nf-core/fq/lint/main'
 include { MULTIQC                          } from './modules/nf-core/multiqc/main'


// Print parameter summary log to screen before running
log.info paramsSummaryLog(workflow)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NFSTEM {

    ch_versions = Channel.empty()
    ch_multiqc  = Channel.empty()

    INITIALISE()

    // See the documentation https://nextflow-io.github.io/nf-validation/samplesheets/fromSamplesheet/
    Channel
        .fromSamplesheet('input')
        // Coerces from [ meta, fastq1, fastq2 ] to [ meta, [ fastq1, fastq2 ] ]. Required for nf-core modules.
        // See https://github.com/nextflow-io/nf-validation/issues/81
        .map { meta, fastq1, fastq2 -> fastq2 ? tuple(meta, [fastq1, fastq2]) : tuple(meta, [fastq1]) }
        .set { ch_input }

    ch_adapters = params.adapter_fasta ? Channel.fromFile(params.adapter_fasta).collect() : Channel.of([])

    FQ_LINT(ch_input)
    ch_versions = ch_versions.mix(FQ_LINT.out.versions)
    ch_multiqc  = ch_multiqc.mix(FQ_LINT.out.lint)

    TRIM(
        ch_input,                 // file: [ meta, fastq.gz ]
        params.skip_fastqc,       // boolean: true/false
        params.umi,               // boolean: true/false
        params.skip_umi_extract,  // boolean: true/false
        params.umi_discard_read,  // integer: 0, 1 or 2
        params.skip_trimming,     // boolean: true/false
        ch_adapters,              // file: adapter.fasta
        params.save_trimmed_fail, // boolean: true/false
        params.save_merged,       // boolean: true/false
        params.min_trimmed_reads  // integer: > 0
    )
    ch_versions = ch_versions.mix(TRIM.out.versions)
    ch_multiqc  = ch_multiqc.mix(TRIM.out.multiqc)


    MULTIQC(
        ch_multiqc.collect{ it[1] },
        [],
        [], 
        []
    )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow {
    NFSTEM ()
}
