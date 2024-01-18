#! /usr/bin/env nextflow
nextflow.enable.dsl = 2


// get NCBI BLAST databases
params.genome = "ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz"
// https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz

// database name 
params.dbname = "nt"

// Downloading the dataset from NCBI
process downloadNCBIdb {
    publishDir "${ params.outdir }/nt_db", mode: 'copy'
    output:
        path "nt.fasta", emit: ncbi_nt
    script:
        """
        wget $params.genome -O nt.fasta.gz
        bgzip -@ $task.cpus -d nt.fasta.gz
        """

}

// Build the database 
process makeBlastDb {
    container "ncbi/blast:latest"
    publishDir "${ params.outdir }/nt_db", mode: 'copy'
    input: 
        path ncbi_nt
    output:
        path "*", emit: nt_db
    script:
        """
        makeblastdb -dbtype 'nucl'\
            -in $ncbi_nt \
            -out $params.dbname \
            -input_type 'fasta' -blastdb_version 5 -parse_seqids \
            -title 'Virus Refseq Genomic'
        """
}

// # get annotations
// wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.genomic.gbff.gz
// gunzip viral.1.genomic.gbff.gz

// wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.1.genomic.fna.gz
// gunzip viral.1.1.genomic.fna.gz  // bgzip -@ $task.cpus -d nt.fasta.gz
// makeblastdb -dbtype nucl \
//         -parse_seqids \
//         -in viral.1.1.genomic.fna \ // -in $ncbi_nt
//         -out viral.1.1.genomic \
//         -title 'Virus Refseq Genomic'

workflow CREATEDB {
    main:
        downloadNCBIdb()
        makeBlastDb(downloadNCBIdb.out)
        dbname = makeBlastDb.out

        // dbname = "${ params.outdir }/nt_db/${ params.dbname }"
    emit:
        dbname
}

