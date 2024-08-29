# All content directly copied from 
# https://github.com/nextstrain/ncov/blob/e42576/workflow/snakemake_rules/main_workflow.smk
# https://github.com/nextstrain/ncov/blob/e42576/workflow/snakemake_rules/common.smk


from shlex import (
    quote as shquote,       # shquote() is used in this file and also other workflow files
    split as shsplitwords,
)


def shquotewords(s: str) -> str:
    """
    Split string *s* into (POSIX) shell words, quote each word, and join them
    back into a string.

    This is suitable for properly quoting multi-word, user-defined values which
    should follow shell quoting and escaping semantics (e.g. to allow spaces in
    single words) but not allow shell features like variable interpolation,
    command substition, redirection, piping, etc.
    """
    return " ".join(shquote(word) for word in shsplitwords(s))


def _get_subsampling_scheme_by_build_name(build_name):
    return config["builds"].get(build_name, {}).get("subsampling_scheme", build_name)


def _get_subsampling_settings(wildcards):
    # Allow users to override default subsampling with their own settings keyed
    # by location type and name. For example, "region_europe" or
    # "country_iceland". Otherwise, default to settings for the location type.
    subsampling_scheme = _get_subsampling_scheme_by_build_name(wildcards.build_name)

    # When there is no well-defined subsampling scheme, default to using all
    # available samples.
    if subsampling_scheme not in config["subsampling"]:
        print(
            f"WARNING: No valid subsampling scheme is defined for build '{wildcards.build_name}'.",
            "Skipping subsampling and using all available samples.",
            file=sys.stderr
        )
        subsampling_scheme = "all"

    subsampling_settings = config["subsampling"][subsampling_scheme]

    if hasattr(wildcards, "subsample"):
        subsampling_settings = subsampling_settings[wildcards.subsample]

        # If users have supplied both `max_sequences` and `seq_per_group`, we
        # throw an error instead of assuming the user prefers one setting over
        # another by default.
        if subsampling_settings.get("max_sequences") and subsampling_settings.get("seq_per_group"):
            raise Exception(f"The subsampling scheme '{subsampling_scheme}' for build '{wildcards.build_name}' defines both `max_sequences` and `seq_per_group`, but these arguments are mutually exclusive. If you didn't define both of these settings, this conflict could be caused by using the same subsampling scheme name as a default scheme. In this case, rename your subsampling scheme, '{subsampling_scheme}', to a unique name (e.g., 'custom_{subsampling_scheme}') and run the workflow again.")

        # If users have defined `group_by` but supplied neither `max_sequences` nor `seq_per_group`, we
        # throw an error because the subsampling rule will still group by one or
        # more fields and the lack of limits on this grouping could produce
        # unexpected behavior.
        if subsampling_settings.get("group_by") and not subsampling_settings.get("max_sequences") and not subsampling_settings.get("seq_per_group"):
            raise Exception(f"The subsampling scheme '{subsampling_scheme}' for build '{wildcards.build_name}' must define `max_sequences` or `seq_per_group`.")

    return subsampling_settings


def get_priorities(wildcards):
    subsampling_settings = _get_subsampling_settings(wildcards)

    if "priorities" in subsampling_settings and subsampling_settings["priorities"]["type"] == "proximity":
        return f"{build_dir}/{wildcards.build_name}/priorities_{subsampling_settings['priorities']['focus']}.tsv"
    else:
        # TODO: find a way to make the list of input files depend on config
        return config["include"]


def get_priority_argument(wildcards):
    subsampling_settings = _get_subsampling_settings(wildcards)
    if "priorities" not in subsampling_settings:
        return ""

    if subsampling_settings["priorities"]["type"] == "proximity":
        return "--priority " + shquote(get_priorities(wildcards))
    elif subsampling_settings["priorities"]["type"] == "file" and "file" in subsampling_settings["priorities"]:
        return "--priority " + shquote(subsampling_settings["priorities"]["file"])
    else:
        return ""


def _get_specific_subsampling_setting(setting, optional=False):
    # Note -- this function contains a lot of conditional logic because
    # we have the situation where some config options must define the
    # augur argument in their value, and some must not. For instance:
    # subsamplingScheme -> sampleName -> group_by: year                            (`--group-by` is _not_ part of this value)
    #                                 -> exclude: "--exclude-where 'country=USA'"  (`--exclude-where` IS part of this value)
    # Since there are a lot of subsampling schemes out there, backwards compatability
    # is important!                                 james hadfield, feb 2021
    def _get_setting(wildcards):
        if optional:
            value = _get_subsampling_settings(wildcards).get(setting, "")
        else:
            value = _get_subsampling_settings(wildcards)[setting]

        if isinstance(value, str):
            # Load build attributes including geographic details about the
            # build's region, country, division, etc. as needed for subsampling.
            if wildcards.build_name not in config["builds"]:
                raise Exception(f"The requested build name {wildcards.build_name!r} does not exist in the given configuration file. This error occurred while looking up the subsampling setting {setting!r}. This missing build might indicate a typo in the build name.")

            build = config["builds"][wildcards.build_name]
            value = value.format(**build)
            if value !="":
                if setting == 'exclude_ambiguous_dates_by':
                    value = f"--exclude-ambiguous-dates-by {value}"
                elif setting == 'group_by':
                    value = f"--group-by {value}"
                elif setting == 'group_by_weights':
                    value = f"--group-by-weights {value}"
        elif value is not None:
            # If is 'seq_per_group' or 'max_sequences' build subsampling setting,
            # need to return the 'argument' for augur
            if setting == 'seq_per_group':
                value = f"--sequences-per-group {value}"
            elif setting == 'max_sequences':
                value = f"--subsample-max-sequences {value}"

            return shquotewords(value)
        else:
            value = ""

        # Check format strings that haven't been resolved.
        if re.search(r'\{.+\}', value):
            raise Exception(f"The parameters for the subsampling scheme '{wildcards.subsample}' of build '{wildcards.build_name}' reference build attributes that are not defined in the configuration file: '{value}'. Add these build attributes to the appropriate configuration file and try again.")

        return shquotewords(value)

    return _get_setting


def _get_subsampled_files(wildcards):
    subsampling_settings = _get_subsampling_settings(wildcards)

    return [
        f"{build_dir}/{wildcards.build_name}/sample-{subsample}.txt"
        for subsample in subsampling_settings
    ]
