#! /usr/bin/env nextflow

 def helpMessage() {
    log.info "PI BLAST v1.0"
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:

    nextflow run PI-Bioinfo/BLAST --genome "genomeURL" --dbname "blastPrefixName" --csvDir "<design CSV file on S3>" \
                         -profile awsbatch -work-dir "<work dir on S3>" --awsqueue "<SQS ARN>" --outdir "<output dir on S3>"

    Mandatory arguments:
        -profile                      Configuration profile to use. Can use multiple (comma separated)
                                      Available: conda, docker, singularity, awsbatch, test and more.
        --csvDir                      Path to a CSV file with sample labels and input data locations.
        --genome                      Link to genome references
        --dbname                      Name for blastn database  
   
    Optional arguments:
        --outdir                      Output directory to place final BLAST output
        --outfmt                      Output format [6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue staxids stitle sblastnames]
        --help                        This usage statement.
    
    AWSBatch options:
        --awsqueue                    The AWSBatch JobQueue that needs to be set when running on AWSBatch
        --awsregion                   The AWS Region for your AWS Batch job to run on
    
    Cloudfront options:
        --cloudfront_origin_path      The origin path for Cloudfront
        --cloudfront_domain_name      The domain name for Cloudfront
        --cloudfront_private_key_ID   The private key ID for Cloudfront
        --cloudfront_privateKey       The location of the private key file for Cloudfront, if not provided, download links will not be included in the report
     """
 }


 // Show help message
 if (params.help) {
     helpMessage()
     exit 0
 }