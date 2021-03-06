process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::minimap2=2.21 bioconda::samtools=1.11 conda-forge::pigz=2.3.4' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/minimap2:2.21--h5bf99c6_0' :
        'quay.io/biocontainers/minimap2:2.21--h5bf99c6_0' }"

   input:
    tuple val(meta), path(reads)
    path reference

    output:
    tuple val(meta), path("*.sam"), emit: sam
    path "versions.yml" , emit: versions

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_reads = meta.single_end ? "$reads" : "${reads[0]} ${reads[1]}"
    """
    minimap2 $args -t $task.cpus $reference $input_reads  > ${prefix}.sam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version 2>&1)
    END_VERSIONS
    """
}
