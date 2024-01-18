params.chunkpercent = 0.05

// Calculate and randomize n% reads, subset file
process CALCULATEREADS {
    publishDir "$baseDir/numsample", mode: 'copy'
    input: 
        tuple val( sample ), path( reads )
    output:
        path "*_numsample.txt", emit: numsample
    script:
    """
    if [[ -f "$reads" ]]; then
        if [[ "$reads" =~ ".fastq.gz"\$|".fq.gz"\$ ]]; then
            echo "\$(zcat $reads | wc -l)/4 * $params.chunkpercent" | bc -l | xargs printf "%.0f" > ${ sample }_numsample.txt
        else
            echo "Unsupported file format: $reads"
            exit 1
        fi
    else
        echo "The reads file does not exist: $reads"
        exit 1
    fi
    
    """
}

process SUBSETFILE {
    container "chaudb/seqtk:latest"
    publishDir "$baseDir/subsetquery", mode: 'copy'
    input:
        tuple val( sample ), path( reads )
        path numsample
    output:
        path "*.fasta" 
    script:
    """
    num=\$(cat $numsample)
    seqtk sample -s100 $reads \$num | seqtk seq -a - > ${ sample }.fasta
    """
}