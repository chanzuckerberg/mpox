We adapted the workflow, the description and the acknowledgement below from the Nextstrain team's [mpox workflow](https://github.com/nextstrain/mpox), with additional functionalities to add closely related contextual data.

#### Acknowledgement
We gratefully acknowledge the authors, originating and submitting laboratories of the genetic sequences and metadata for sharing their work. Please note that although data generators have generously shared data in an open fashion, that does not mean there should be free license to publish on this data. Data generators should be cited where possible and collaborations should be sought in some circumstances. Please try to avoid scooping someone else's work. Reach out if uncertain.

We also acknowledge the Nextstrain team's effort in creating this workflow, curating and processing publicly available data for the community to use.

#### Analysis
Our bioinformatic processing workflow can be found at [github.com/chanzuckerberg/mpox](https://github.com/chanzuckerberg/mpox) in the branch `subsample_by_distance` and includes:
- sequence alignment by [nextalign](https://docs.nextstrain.org/projects/nextclade/en/stable/user/nextalign-cli.html) against the [reference sequence MPXV-M5312_HM12_Rivers](https://www.ncbi.nlm.nih.gov/nuccore/NC_063383)
- add closely related contextual sequences curated by Nexstrain team using data from [NCBI Virus](https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Nucleotide&VirusLineage_ss=Monkeypox%20virus,%20taxid:10244)
Pairwise alignments with [Nextclade](https://clades.nextstrain.org/). To download these curated data, please see Nextstrain team's [mpox tree page](https://nextstrain.org/monkeypox/hmpxv1).
- masking several regions of the genome, including the first 1500 and last 7000 base pairs and a repetitive region of variable length
- phylogenetic reconstruction using [IQTREE](http://www.iqtree.org/)
- ancestral state reconstruction and temporal inference using [TreeTime](https://github.com/neherlab/treetime)
- clade assignment via [clade definitions defined here](https://github.com/nextstrain/monkeypox/blob/master/config/clades.tsv), to label broader MPXV clades 1, 2 and 3 and to label hMPXV1 lineages A, A.1, A.1.1, etc...
