"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

REQUIRED INPUTS:

    include     = path to file of sequences to in force include
    reference   = path to reference sequence FASTA for Nextclade alignment
    genome_annotation     = path to genome_annotation GFF for Nextclade alignment
    maskfile    = path to maskfile of sites to be masked

OUTPUTS:

    prepared_sequences = {build_dir}/{build_name}/masked.fasta

"""


rule filter:
    """
    Removing strains that do not satisfy certain requirements.
    """
    input:
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv",
        exclude="defaults/exclude_accessions.txt",
    output:
        sequences=build_dir + "/{build_name}/good_sequences.fasta",
        metadata=build_dir + "/{build_name}/good_metadata.tsv",
        log=build_dir + "/{build_name}/good_filter.log",
    params:
        min_date=config["filter"]["min_date"],
        min_length=config["filter"]["min_length"],
        strain_id=config["strain_id_field"],
        exclude_where=lambda w: (
            f"--exclude-where {config['filter']['exclude_where']}"
            if "exclude_where" in config["filter"]
            else ""
        ),
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --output-sequences {output.sequences} \
            --output-metadata {output.metadata} \
            --exclude {input.exclude} \
            {params.exclude_where} \
            --min-date {params.min_date} \
            --min-length {params.min_length} \
            --query "(QC_rare_mutations == 'good' | QC_rare_mutations == 'mediocre' | QC_rare_mutations == '')" \
            --output-log {output.log}
        """


"""
The section below until right before rule 'mask' are copied from ncov workflow (e42576) with inputs and outputs modified as needed.
"""

rule index_sequences:
    message:
        """
        Index sequence composition for faster filtering.
        """
    input:
        sequences = build_dir + "/{build_name}/good_sequences.fasta"
    output:
        sequence_index = build_dir + "/{build_name}/good_sequence_index.tsv.xz"
    log:
        build_dir + "/{build_name}/logs/index_sequences.txt"
    benchmark:
        build_dir + "/{build_name}/benchmarks/index_sequences.txt"
    shell:
        """
        augur index \
            --sequences {input.sequences} \
            --output {output.sequence_index} 2>&1 | tee {log}
        """


rule subsample:
    message:
        """
        Subsample all sequences by '{wildcards.subsample}' scheme for build '{wildcards.build_name}' with the following parameters:

         - group by: {params.group_by}
         - sequences per group: {params.sequences_per_group}
         - subsample max sequences: {params.subsample_max_sequences}
         - min-date: {params.min_date}
         - max-date: {params.max_date}
         - {params.exclude_ambiguous_dates_argument}
         - exclude: {params.exclude_argument}
         - include: {params.include_argument}
         - query: {params.query_argument}
         - priority: {params.priority_argument}
        """
    input:
        metadata = build_dir + "/{build_name}/good_metadata.tsv",
        include = config["include"],
        priorities = get_priorities,
        exclude = "defaults/exclude_accessions.txt"
    output:
        strains=build_dir + "/{build_name}/sample-{subsample}.txt",
    log:
        build_dir + "/{build_name}/logs/subsample_{build_name}_{subsample}.txt"
    benchmark:
        build_dir + "/{build_name}/benchmarks/subsample_{build_name}_{subsample}.txt"
    params:
        group_by = _get_specific_subsampling_setting("group_by", optional=True),
        group_by_weights = _get_specific_subsampling_setting("group_by_weights", optional=True),
        sequences_per_group = _get_specific_subsampling_setting("seq_per_group", optional=True),
        subsample_max_sequences = _get_specific_subsampling_setting("max_sequences", optional=True),
        sampling_scheme = _get_specific_subsampling_setting("sampling_scheme", optional=True),
        exclude_argument = _get_specific_subsampling_setting("exclude", optional=True),
        include_argument = _get_specific_subsampling_setting("include", optional=True),
        query_argument = _get_specific_subsampling_setting("query", optional=True),
        exclude_ambiguous_dates_argument = _get_specific_subsampling_setting("exclude_ambiguous_dates_by", optional=True),
        min_date = _get_specific_subsampling_setting("min_date", optional=True),
        max_date = _get_specific_subsampling_setting("max_date", optional=True),
        priority_argument = get_priority_argument,
        strain_id=config["strain_id_field"],
    shell:
        """
        augur filter \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --include {input.include} \
            --exclude {input.exclude} \
            {params.min_date} \
            {params.max_date} \
            {params.exclude_argument} \
            {params.include_argument} \
            {params.query_argument} \
            {params.exclude_ambiguous_dates_argument} \
            {params.priority_argument} \
            {params.group_by} \
            {params.group_by_weights} \
            {params.sequences_per_group} \
            {params.subsample_max_sequences} \
            {params.sampling_scheme} \
            --output-strains {output.strains} 2>&1 | tee {log}
        """


rule extract_subsampled_sequences:
    input:
        alignment=build_dir + "/{build_name}/good_sequences.fasta",
        metadata=build_dir + "/{build_name}/good_metadata.tsv",
        sequence_index = rules.index_sequences.output.sequence_index,
        strains=build_dir + "/{build_name}/sample-{subsample}.txt",
    output:
        subsampled_sequences = build_dir + "/{build_name}/sample-{subsample}.fasta",
    params:
        strain_id=config["strain_id_field"],
    log:
        build_dir + "/{build_name}/logs/extract_subsampled_sequences_{build_name}_{subsample}.txt"
    benchmark:
        build_dir + "/{build_name}/benchmarks/extract_subsampled_sequences_{build_name}_{subsample}.txt"
    shell:
        """
        augur filter \
            --metadata {input.metadata} \
            --sequences {input.alignment} \
            --metadata-id-columns {params.strain_id} \
            --sequence-index {input.sequence_index} \
            --exclude-all \
            --include {input.strains} \
            --output-sequences {output.subsampled_sequences} 2>&1 | tee {log}
        """


rule proximity_score:
    message:
        """
        determine priority for inclusion in as phylogenetic context by
        genetic similiarity to sequences in focal set for build '{wildcards.build_name}'.
        """
    input:
        alignment = build_dir + "/{build_name}/good_sequences.fasta",
        reference = config["reference"],
        focal_alignment = build_dir + "/{build_name}/sample-{focus}.fasta"
    output:
        proximities = build_dir + "/{build_name}/proximity_{focus}.tsv"
    log:
        build_dir + "/{build_name}/logs/subsampling_proximity_{build_name}_{focus}.txt"
    benchmark:
        build_dir + "/{build_name}/benchmarks/proximity_score_{build_name}_{focus}.txt"
    params:
        chunk_size=10000,
    shell:
        """
        python3 scripts/get_distance_to_focal_set.py \
            --reference {input.reference} \
            --alignment {input.alignment} \
            --focal-alignment {input.focal_alignment} \
            --chunk-size {params.chunk_size} \
            --output {output.proximities} 2>&1 | tee {log}
        """


rule priority_score:
    input:
        proximity = rules.proximity_score.output.proximities,
        sequence_index = rules.index_sequences.output.sequence_index,
    output:
        priorities = build_dir + "/{build_name}/priorities_{focus}.tsv"
    benchmark:
        "benchmarks/priority_score_{build_name}_{focus}.txt"
    params:
        crowding = config["priorities"]["crowding_penalty"],
        Nweight = 0.003
    shell:
        """
        python3 scripts/priorities.py \
            --sequence-index {input.sequence_index} \
            --proximities {input.proximity} \
            --crowding-penalty {params.crowding} \
            --Nweight {params.Nweight} \
            --output {output.priorities} 2>&1 | tee {log}
        """


rule combine_samples:
    message:
        """
        Combine and deduplicate FASTAs
        _get_unified_alignment will combine all subsampled sequences
        """
    input:
        sequences=build_dir + "/{build_name}/good_sequences.fasta",
        metadata=build_dir + "/{build_name}/good_metadata.tsv",
        include=_get_subsampled_files,
    output:
        sequences = build_dir + "/{build_name}/{build_name}_subsampled_sequences.fasta",
        metadata = build_dir + "/{build_name}/metadata.tsv"
    params:
        strain_id=config["strain_id_field"],
    log:
        build_dir + "/{build_name}/logs/subsample_regions_{build_name}.txt"
    benchmark:
        build_dir + "/{build_name}/benchmarks/subsample_regions_{build_name}.txt"
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --exclude-all \
            --include {input.include} \
            --output-sequences {output.sequences} \
            --output-metadata {output.metadata} 2>&1 | tee {log}
        """


rule mask:
    """
    Mask ends of the alignment:
      - from start: {params.from_start}
      - from end: {params.from_end}
    """
    input:
        sequences=build_dir + "/{build_name}/{build_name}_subsampled_sequences.fasta",
        mask=config["mask"]["maskfile"],
    output:
        build_dir + "/{build_name}/masked.fasta",
    params:
        from_start=config["mask"]["from_beginning"],
        from_end=config["mask"]["from_end"],
    shell:
        """
        augur mask \
            --sequences {input.sequences} \
            --mask {input.mask} \
            --mask-from-beginning {params.from_start} \
            --mask-from-end {params.from_end} --output {output}
        """
