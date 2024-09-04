# CZ Gen Epi fork of nextstrain/mpox
This is a fork of the [Nextstrain/mpox repo](https://github.com/nextstrain/mpox) for use in CZ Gen Epi.

This fork exists for two primary reasons:
1. To provide subsampling with mpox closer to how we did targeted subsampling for SARS-CoV-2. See the [Nextstrain/ncov repo](https://github.com/nextstrain/ncov) for the original version of that. Our code bringing that in to this fork is present in this repo's `subsample_by_distance` branch.
2. For maintenance purposes, so the CZ Gen Epi app is pinned to using a specific commit we can control.

**Make sure to look at the `subsample_by_distance` branch** of this repo! That's the branch that CZ Gen Epi uses for its mpox tree building workflow.

------------------------------

# Nextstrain repository for mpox virus

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/nextstrain/mpox/master.svg)](https://results.pre-commit.ci/latest/github/nextstrain/mpox/master)

This repository contains three workflows for the analysis of mpox virus (MPXV) data:

- [`ingest/`](./ingest) - Download data from GenBank, clean and curate it and upload it to S3
- [`phylogenetic/`](./phylogenetic) - Filter sequences, align, construct phylogeny and export for visualization
- [`nextclade/`](./nextclade) - Make Nextclade datasets for nextstrain/nextclade_data

Each folder contains a README.md with more information. The results of running both workflows are publicly visible at [nextstrain.org/mpox](https://nextstrain.org/mpox).

## Installation

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html) for Nextstrain's suite of software tools.

## Quickstart

Run the default phylogenetic workflow via:
```
cd phylogenetic/
nextstrain build .
nextstrain view .
```

## Documentation

- [Running a pathogen workflow](https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html)
- [Contributor documentation](./CONTRIBUTING.md)
