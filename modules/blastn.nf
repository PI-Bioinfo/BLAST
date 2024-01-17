params.dbname = "nt"
params.outfmt = "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue staxids stitle sblastnames"
params.remove = ""
params.add = ""
params.num_hits = 10

list_outfmt = params.outfmt.tokenize(" ")
list_remove = params.remove.tokenize(" ")
list_add = params.add.tokenize(" ")

list_outfmt = list_outfmt - list_remove + list_add

// list_outfmt = list_outfmt - list_remove + list_add

// Performs a BLASTN sequence search and captures the 10 top species, sorting to e-value
process BLASTSEARCH {
    container "ncbi/blast:latest"
    publishDir "$baseDir/results", mode: 'copy'
    input: 
        tuple val ( sample ), path( reads )
        path sub_query 
        path nt_db
    output:
        path "*_top_species.txt", emit: txt
    script:

        """
        X="$list_outfmt"
        Y=\$(echo \$X | sed 's/[][]//g' | sed 's/, / /g')
        
        blastn -db $params.dbname -query $sub_query -outfmt "\$Y" > blast_result
        cat blast_result | sort -k11,11g | head -n $params.num_hits | cut -f 13 > ${ sample }_top_species.txt
        """
}  

// | awk \"!seen[13]++\"