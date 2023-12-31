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

 include { INITIALISE          } from './subworkflows/local/initialise'

 include { FQ_LINT             } from './modules/nf-core/fq/lint/main'


// Print parameter summary log to screen before running
log.info paramsSummaryLog(workflow)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NFSTEM {

    ch_versions = Channel.empty()

    INITIALISE()

    // See the documentation https://nextflow-io.github.io/nf-validation/samplesheets/fromSamplesheet/
    Channel
        .fromSamplesheet('input')
        // Coerces from [ meta, fastq1, fastq2 ] to [ meta, [ fastq1, fastq2 ] ]. Required for nf-core modules.
        // See https://github.com/nextflow-io/nf-validation/issues/81
        .map { meta, fastq1, fastq2 -> fastq2 ? tuple(meta, [fastq1, fastq2]) : tuple(meta, [fastq1]) }
        .set { ch_input }

    FQ_LINT(ch_input)

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow {
    NFSTEM ()
}
