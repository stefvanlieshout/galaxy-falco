FALCO Amplicon Analysis Pipeline & Galaxy wrapper
========================================

FALCO variant-caller is part of the Amplicon Analysis Pipeline (AAP).

The typical workflow is as follows:
* paired-end amplicon sequencing
* merge pairs (so only overlapping pairs are included)
* map the single read fastq with BWA
* perform variant calling with FALCO
* create (html) report of the results

FALCO uses samtools and straight-forward statistics to determine wether a
potential variant is likely a (technical) artifact or not.

Input / Output

Input of the caller is a BAM file, output VCF


Bug Reports & other questions
=============================

Issues can be reported via http://www.tgac.nl/
