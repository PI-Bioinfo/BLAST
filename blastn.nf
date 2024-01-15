// Performs a BLASTN sequence search and captures the 10 top species, sorting to e-value
process blastsearch {
    container "ncbi/blast:latest"
    publishDir "$baseDir/results", mode: 'copy'
    input: 
        tuple val(sample), path(reads)
        path sub_query
        path nt_db 
    output:
        path "*_top_species.txt"
    script: 
        """
        blastn -db $params.dbname -query $sub_query -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue staxids stitle sblastnames" > blast_result
        cat blast_result | sort -k11,11g | head -n 10 | cut -f 13 > ${ sample }_top_species.txt
        """
}  

// | awk \"!seen[13]++\"
