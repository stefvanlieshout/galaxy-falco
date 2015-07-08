FALCO Galaxy tool
====================

This galaxy-tool is a wrapper for the Amplicon Variant Caller FALCO

FALCO is part of the Amplicon Analysis Pipeline (AAP).

The typical workflow is as follows:
* paired-end amplicon sequencing
* merge pairs (so only overlapping pairs are included)
* map the single read fastq with BWA
* perform variant calling with FALCO (input=BAM, output=VCF)
* create (html) report of the results

FALCO uses samtools and straight-forward statistics to determine wether a
potential variant is likely a (technical) artifact or not.

For questions/remarks about the underlying tool itself, see [FALCO at github]. Issues can also be reported the via [TGAC website]

[Falco at github]: https://github.com/tgac-vumc/falco/
[TGAC website]: http://www.tgac.nl/

Installation
---------------------

This tool should be installed into a galaxy installation from the (test)toolshed (tool-name: falco).


Citation
---------------------

For the underlying tool please cite: 

Daoud Sie, Peter J.F. Snijders, Gerrit A. Meijer, Marije W. Doeleman, Marinda I. H. van Moorsel, Hendrik F. van Essen, Paul P. Eijk, Katrien Grünberg, Nicole C. T. van Grieken, Erik Thunnissen, Henk M. Verheul, Egbert F. Smit, Bauke Ylstra, Daniëlle A. M. Heideman "Performance of amplicon-based next generation DNA sequencing for diagnostic gene mutation profiling in oncopathology" Cellular Oncology 37.5 (2014):353-361 doi:10.1007/s13402-014-0196-2

