#!/bin/bash

#TOOLDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Started FALCO calling"

## ----------
## Variables setup ($1 contains the bash config file path)
## ----------
source $1
TOOLDIR=$2

## ----------
## make sure all is ok
## ----------
#if [ ! -f $REF_FILE".fai" ]
#then
#	echo "No FAI index (fai) found for reference fasta [$REF_FILE]"
#	exit "No FAI index (fai) found for reference fasta [$REF_FILE]"
#fi

## ----------
## set params
## ----------
if [[ $vcf2_file != 'None' && $vcf2_file != '' ]] # Galaxy default is "None" for some reason
then 
	VCF2_PARAM=" --vcfOther "$vcf2_file
else
	VCF2_PARAM=""
fi

# if [[ $manifest_file != 'None' && $manifest_file != 'None' ]] # Galaxy default is "None" for some reason
# then 
# 	MANIFEST_PARAM=" --manifest "$manifest_file
# else
# 	MANIFEST_PARAM=""
# fi

## name of file in galaxy not always set so will use a user-set job_name instead
#bam_base=`echo $bam_name | sed 's#.bam$##' - ` 
vcf_base=$job_name
sample_html_file=$vcf_base'.html'

## ----------
## Status / debug
## ----------
DEBUG=1
# if [ $DEBUG ]
# then
# 	DBS="[INFO] "
# 	echo $DBS"FILTER:   "$filter_file
# 	echo $DBS"MANIFEST: "$manifest_file
# 	echo $DBS"REF FILE: "$REF_FILE
# 	echo $DBS"DB KEY:   "$DB_KEY
# 	echo $DBS"REF SRC:  "$REF_SOURCE
# 	echo $DBS"BAM FILE: "$bam_file
# 	echo $DBS"BAM NAME: "$bam_name
# 	echo $DBS"BAM BASE: "$bam_base
# 	echo $DBS"OUT PATH: "$out_path
# fi

## ----------
## create output files dir
## ----------
mkdir $out_path

## ----------
## running analysis
## ----------
echo "[INFO] Starting FALCO reporting"
CMD_STRING="$TOOLDIR/falco/bin/falco-filter-report --vcf $vcf_file --output $vcf_base --qc_ann_qual_txt $qc_ann_qual_file --qc2_ann_txt $qc2_ann_txt_file --qc_targets_txt $qc_targets_txt_file $VCF2_PARAM"
echo "[INFO] "$CMD_STRING
perl $CMD_STRING
echo "[INFO] done with FALCO reporting"


## ----------
## create index html for main galaxy output
## ----------
echo "<!DOCTYPE html>" >> $html_out
echo "<html>" >> $html_out
echo "<head>" >> $html_out
echo "<style>" >> $html_out
echo "    body{ padding: 0px 20px; }" >> $html_out
echo "    h1{ color: red; }" >> $html_out
echo "    table{ border: 1px solid black; padding: 5px }" >> $html_out
echo "</style>" >> $html_out
echo "</head>" >> $html_out
echo "<body>" >> $html_out
echo "	<h1>FALCO</h1>" >> $html_out
echo "  <a href=\"$sample_html_file\">RESULTS</a>" >> $html_out
#echo "	<p>This page is way to get output files that are not implemented in galaxy history, it is not intended to be a user-friendly way of displaying anything ;)</p>" >> $html_out
#echo "	<a href=\"index.html\">HTML</a>" >> $html_out
#echo "	<table><tbody>" >> $html_out
#for file in *.vcf *.txt *stderr *stdout
#for file in *
#do
#	lineCount=`wc -l $file | cut -f 1 -d " "`
#	echo "	<tr><td><a href=\"$file\">$file</a> has $lineCount lines</td></tr>" >> $html_out
#	echo "  <tr><td> --> " `head -1 $file` "</td></tr>" >> $html_out
#done
#echo "	</tbody></table>" >> $html_out
echo "</body>" >> $html_out
echo "</html>" >> $html_out

## ----------
## creating galaxy history outputs
## ----------
#cp 'index.html' $html_out # this is the overview of samples html
cp $sample_html_file $out_path # this is the sample html
#cp $vcf_base'.html' $html_out # this is the sample html

## ----------
## copy files to keep to output path
## ----------
#cp -r ./$bam_base/*png $out_path/$bam_base/
cp -r ./* $out_path
#cp *.vcf $out_path; cp *.txt $out_path; cp *_std* $out_path

## ----------
echo "END falco sh"
exit 0
