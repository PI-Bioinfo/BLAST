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
            .map{ PARSE_DESIGN(it) }
            .view()
    
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
    BLASTSEARCH( reads_ch,sub_query,db ) 
    BLASTSEARCH.out.view()
}


def PARSE_DESIGN(LinkedHashMap row) {
     reads = row.read_1 ?: row.read_2 ?: null

     if (reads == null) {
          error('Need to provide at least one read path')
     }

     return tuple(row.sample,file(reads))
}