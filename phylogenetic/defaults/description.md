We adapted the workflow, the description and the acknowledgement below from the Nextstrain team's [mpox workflow](https://github.com/nextstrain/mpox), with additional functionalities to add closely related contextual data similar to Nextstrain teams's [ncov workflow](https://github.com/nextstrain/ncov).

#### Acknowledgement
We gratefully acknowledge the authors, originating and submitting laboratories of the genetic sequences and metadata for sharing their work. Please note that although data generators have generously shared data in an open fashion, that does not mean there should be free license to publish on this data. Data generators should be cited where possible and collaborations should be sought in some circumstances. Please try to avoid scooping someone else's work. Reach out if uncertain.

We also acknowledge the Nextstrain team's effort in creating this workflow, curating and processing publicly available data for the community to use.

#### Analysis
We used aligned sequences and metadata from the NCBI Datasets curated by the Nextstream team as starting point for these analyses (more details see the `Underlying data` section of [https://nextstrain.org/mpox/all-clades](https://nextstrain.org/mpox/all-clades)):

- [data.nextstrain.org/files/workflows/mpox/alignment.fasta.xz](https://data.nextstrain.org/files/workflows/mpox/alignment.fasta.xz) (pairwise alignments with Nextclade against the reference sequence [MPXV-M5312_HM12_Rivers](https://www.ncbi.nlm.nih.gov/nuccore/NC_063383))
- [data.nextstrain.org/files/workflows/mpox/metadata.tsv.gz](https://data.nextstrain.org/files/workflows/mpox/metadata.tsv.gz)

Our bioinformatic processing workflow is adopted from the Nextstrain team's [mpox workflow](https://github.com/nextstrain/mpox) and [ncov workflow](https://github.com/nextstrain/ncov). The code can be found at [github.com/chanzuckerberg/mpox](https://github.com/chanzuckerberg/mpox) in the branch `subsample_by_distance` and includes:
- force inclusion of user-selected sequences
- automatically selecting sequences from regions of interest
- add closely related contextual sequences included in the NCBI data curated by the Nexstrain team above
- masking several regions of the genome, including the first 1350 and last 6422 base pairs and a repetitive region of variable length
- removing sequences shorter than 100kb in length
- phylogenetic reconstruction using [IQTREE](http://www.iqtree.org/)
- ancestral state reconstruction and temporal inference using [TreeTime](https://github.com/neherlab/treetime)
- clade assignment via [clade definitions defined here](https://github.com/nextstrain/mpox/blob/-/phylogenetic/defaults/clades.tsv), to label broader MPXV clades 1, 2 and 3 and to label hMPXV1 lineages A, A.1, A.1.1, etc...
