FALCO Galaxy tool
====================

This galaxy-tool is a wrapper for the Amplicon Variant Caller FALCO

It was created to perform variant calling on sequencing data from the TruSeq Amplicon Cancer Panel from Illumina. A typical pre-FALCO workflow would include merging (by overlapping) the reads from a paired-end run, mapping the merged reads to the human genome and use the BAM as input for FALCO.

For questions/remarks about the underlying tool itself, see also FALCO at [github].

[github]: https://github.com/tgac-vumc/falco/


Installation
---------------------

This tool should be installed into a galaxy installation from the (test)toolshed (tool-name: falco).


Citation
---------------------

For the underlying tool please cite: 

Sie, Daoud and Snijders, PeterJ.F. and Meijer, GerritA. and Doeleman, MarijeW. and van Moorsel, MarindaI.H. and van Essen, HendrikF. and Eijk, PaulP. and Grünberg, Katrien and van Grieken, NicoleC.T. and Thunnissen, Erik and Verheul, HenkM. and Smit, EgbertF. and Ylstra, Bauke and Heideman, DaniëlleA.M. "Performance of amplicon-based next generation DNA sequencing for diagnostic gene mutation profiling in oncopathology" Cellular Oncology 37.5 (2014):353-361 doi:10.1007/s13402-014-0196-2

