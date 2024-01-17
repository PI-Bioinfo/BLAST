params.chunkpercent = 0.05

// Parse file design.csv
// Calculate and randomize n% reads, subset file
process calculatereads {
    publishDir "$baseDir/numsample", mode: 'copy'
    input: 
    tuple val(sample), path(reads)
    output:
    path "*_numsample.txt", emit: numsample
    script:
    """
    echo "\$(zcat $reads | wc -l)/4 * $params.chunkpercent" | bc -l | xargs printf "%.0f" > ${ sample }_numsample.txt
    """
}
process subsetfile {
    container "chaudb/seqtk:latest"
    publishDir "$baseDir/subsetquery", mode: 'copy'
    input:
    tuple val(sample), path(reads)
    path numsample
    output:
    path "*.fasta" 
    script:
    """
    num=\$(cat $numsample)
    seqtk sample -s100 $reads \$num > ${ sample }.fastq
    seqtk seq -a ${ sample }.fastq > ${ sample }.fasta
    """
}