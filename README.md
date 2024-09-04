# CZ GEN EPI fork of nextstrain/mpox
This is a fork of the [Nextstrain/mpox repo](https://github.com/nextstrain/mpox) and its `subsample_by_distance` branch is used in CZ GEN EPI.

This fork exists for two primary reasons:
1. To provide subsampling with mpox similar to how it is done for SARS-CoV-2. See [here](https://github.com/nextstrain/mpox/commit/6a7ff1fb99fe4fc714e2b90da1d679e4afd65b4b) for related code changes which are present in the `subsample_by_distance` branch.
2. For maintenance purposes, so the CZ GEN EPI app is pinned to using a specific commit we can control.

<br>
<br>

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
