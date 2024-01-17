#! /usr/bin/env nextflow
nextflow.enable.dsl = 2

// Work directory
params.workdir = "$baseDir/work"
params.outdir = "$baseDir/output"
params.db = null
params.dbname = "nt"

// Query sequences 
params.csvDir = "$baseDir/testdata/design.csv"  

// Load functions
include { CREATEDB } from "$baseDir/modules/makeblastdb" 
include { CALCULATEREADS } from "$baseDir/modules/preblasting"
include { SUBSETFILE } from "$baseDir/modules/preblasting"
include { BLASTSEARCH } from "$baseDir/modules/blastn"

// workflow definition
workflow {
    reads_ch = Channel.fromPath(params.csvDir)
            .splitCsv(header:true)
            .map{ row-> tuple("$row.sample"), file("$row.read_1")}
    
    numsample = CALCULATEREADS( reads_ch ) 
   
    sub_query = SUBSETFILE( reads_ch,numsample )
    // sub_query.view()

    // sub_query_ch = Channel.fromFilePairs('$baseDir/subsetquery/*.fasta', flat: true)          

    if ( params.db ) {
         db = params.db
    } else {
         CREATEDB()
         db = CREATEDB.out
    }
    
    // CREATEDB.out.view()
    BLASTSEARCH( reads_ch,sub_query,CREATEDB.out ) 
    BLASTSEARCH.out.view()
}

