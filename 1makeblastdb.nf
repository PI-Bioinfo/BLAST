// Declare syntax version
nextflow.enable.dsl = 2

// get NCBI BLAST databases
params.ncbi_url = \
"https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz"

// database name 
params.dbname = "nt"

// Downloading the dataset from NCBI
process downloadNCBIdb {
    output:
        path "nt.fasta", emit: ncbi_nt
    script:
        """
        wget ${params.ncbi_url} -O nt.fasta.gz
        gzip -d nt.fasta.gz
        """

}

// Build the database 
process makeBlastDb {
    container "ncbi/blast:latest"
    input: 
        path ncbi_nt
    output:
        path "ncbi_nt*", emit: nt_db
    script:
        """
        sudo apt install ncbi-blast+
        makeblastdb -dbtype 'nucl'\
        -in ${ncbi_nt} -out ${params.dbname} \
        -input_type 'fasta' -blastdb_version 5 -parse_seqids
        """
}
