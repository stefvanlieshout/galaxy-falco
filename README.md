FALCO Galaxy tool
====================

This galaxy-tool is a wrapper for the Amplicon Variant Caller FALCO

FALCO is part of the Amplicon Analysis Pipeline (AAP).

The typical workflow is as follows:
* paired-end amplicon sequencing
* merge pairs (so only overlapping pairs are included)
* map the single read fastq with BWA
* perform variant calling with FALCO
* create (html) report of the results

FALCO uses samtools and straight-forward statistics to determine wether a
potential variant is likely a (technical) artifact or not.

Input / Output:
Input of FALCO is a BAM file, output VCF

For questions/remarks about the underlying tool itself, see also FALCO at [github].
Issues can also be reported via http://www.tgac.nl/

[github]: https://github.com/tgac-vumc/falco/


Installation
---------------------

This tool should be installed into a galaxy installation from the (test)toolshed (tool-name: falco).


Citation
---------------------

For the underlying tool please cite: 

Sie, Daoud and Snijders, PeterJ.F. and Meijer, GerritA. and Doeleman, MarijeW. and van Moorsel, MarindaI.H. and van Essen, HendrikF. and Eijk, PaulP. and Grünberg, Katrien and van Grieken, NicoleC.T. and Thunnissen, Erik and Verheul, HenkM. and Smit, EgbertF. and Ylstra, Bauke and Heideman, DaniëlleA.M. "Performance of amplicon-based next generation DNA sequencing for diagnostic gene mutation profiling in oncopathology" Cellular Oncology 37.5 (2014):353-361 doi:10.1007/s13402-014-0196-2

