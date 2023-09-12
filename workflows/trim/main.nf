 include { FASTQ_FASTQC_UMITOOLS_FASTP      } from '../../subworkflows/nf-core/fastq_fastqc_umitools_fastp/'
 include { FASTQ_FASTQC_UMITOOLS_TRIMGALORE } from '../../subworkflows/nf-core/fastq_fastqc_umitools_trimgalore/'


 workflow TRIM {

        take:
            reads             // file: [ meta, fastq.gz ]
            skip_fastqc       // boolean: true/false
            umi               // boolean: true/false
            skip_umi_extract  // boolean: true/false
            umi_discard_read  // integer: 0, 1 or 2
            skip_trimming     // boolean: true/false
            ch_adapters       // file: adapter.fasta
            save_trimmed_fail // boolean: true/false
            save_merged       // boolean: true/false
            min_trimmed_reads // integer: > 0

        main:
        
        ch_versions = Channel.empty()
        ch_multiqc  = Channel.empty()

        switch ( params.trimmer ) {
            case "fastp":
                FASTQ_FASTQC_UMITOOLS_FASTP(
                    reads,             // file: [ meta, fastq.gz ]
                    skip_fastqc,       // boolean: true/false
                    umi,               // boolean: true/false
                    skip_umi_extract,  // boolean: true/false
                    umi_discard_read,  // integer: 0, 1 or 2
                    skip_trimming,     // boolean: true/false
                    ch_adapters,       // file: adapter.fasta
                    save_trimmed_fail, // boolean: true/false
                    save_merged,       // boolean: true/false
                    min_trimmed_reads  // integer: > 0
                )
                trimmed_reads = FASTQ_FASTQC_UMITOOLS_FASTP.out.reads
                ch_versions = ch_versions.mix(FASTQ_FASTQC_UMITOOLS_FASTP.out.versions)
                ch_multiqc  = ch_multiqc.mix(
                    FASTQ_FASTQC_UMITOOLS_FASTP.out.fastqc_raw_zip, 
                    FASTQ_FASTQC_UMITOOLS_FASTP.out.trim_json, 
                    FASTQ_FASTQC_UMITOOLS_FASTP.out.fastqc_trim_zip, 
                    FASTQ_FASTQC_UMITOOLS_FASTP.out.umi_log
                )
                break
            case "trimgalore":
                FASTQ_FASTQC_UMITOOLS_TRIMGALORE(
                    reads,              // file: [ meta, fastq.gz ]
                    skip_fastqc,        // boolean: true/false
                    umi,                // boolean: true/false
                    skip_umi_extract,   // boolean: true/false
                    skip_trimming,      // boolean: true/false
                    umi_discard_read,   // integer: 0, 1 or 2
                    min_trimmed_reads   // integer: > 0
                )
                trimmed_reads = FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.reads
                ch_versions = ch_versions.mix(FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.versions)
                ch_multiqc  = ch_multiqc.mix(
                    FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.fastqc_zip, 
                    FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.trim_log, 
                    FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.umi_log
                )
                break
            default:
                trimmed_reads = ch_input
                break
            }
        
        emit:
            reads    = trimmed_reads
            versions = ch_versions
            multiqc  = ch_multiqc
 }