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
if [ ! -f $REF_FILE".fai" ]
then
	echo "No FAI index (fai) found for reference fasta [$REF_FILE]"
	exit "No FAI index (fai) found for reference fasta [$REF_FILE]"
fi

## ----------
## set params
## ----------
if [[ $filter_file != 'None' && $filter_file != '' ]] # Galaxy default is "None" for some reason
then 
	FILTER_PARAM=" --filter "$filter_file
else
	FILTER_PARAM=""
fi

if [[ $manifest_file != 'None' && $manifest_file != 'None' ]] # Galaxy default is "None" for some reason
then 
	MANIFEST_PARAM=" --manifest "$manifest_file
else
	MANIFEST_PARAM=""
fi

## name of file in galaxy not always set so will use a user-set job_name instead
#bam_base=`echo $bam_name | sed 's#.bam$##' - ` 
bam_base=$job_name

## in case of test run (re)set params
if [[ $test_run == 'true' ]]
then 
	MANIFEST_PARAM=""
	FILTER_PARAM=""
	bam_file=$TOOLDIR/tool-data/HCT116_test_ABL1.bam
	#bam_base="GALAXY-FALCO-TEST"
fi

## ----------
## Status / debug
## ----------
DEBUG=1
if [ $DEBUG ]
then
	DBS="[INFO] "
	echo $DBS"FILTER: "$filter_file
	echo $DBS"MANIFEST: "$manifest_file
	echo $DBS"REF FILE: "$REF_FILE
	echo $DBS"DB KEY: "$DB_KEY
	echo $DBS"REF SRC: "$REF_SOURCE
	echo $DBS"BAM FILE: "$bam_file
	echo $DBS"BAM NAME: "$bam_name
	echo $DBS"BAM BASE: "$bam_base
	echo $DBS"OUT PATH: "$out_path
fi

## ----------
## create output files dir
## ----------
mkdir $out_path

## ----------
## running analysis
## ----------
echo "[INFO] Starting variant calling"
## NOTE: if $FILTER_PARAM is set it includes the param name (--filter)
## NOTE: if $MANIFEST_PARAM is set it includes the param name (--manifest)
CALL_STRING="$TOOLDIR/falco/bin/falco --bam $bam_file --output $bam_base --ref $REF_FILE $FILTER_PARAM $MANIFEST_PARAM"
echo "[INFO] "$CALL_STRING
perl $CALL_STRING
echo "[INFO] done with variant calling"


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
echo "	<p>This page is way to get output files that are not implemented in galaxy history, it is not intended to be a user-friendly way of displaying anything ;)</p><p>Also not all files might have been copied. To delete this files below from the galaxy installation delete the html page in your history.." >> $html_out
#echo "	<a href=\"index.html\">HTML</a>" >> $html_out
echo "	<table><tbody>" >> $html_out
for file in *.vcf *.txt *stderr *stdout
#for file in *
do
	lineCount=`wc -l $file | cut -f 1 -d " "`
	echo "	<tr><td><a href=\"$file\">$file</a> has $lineCount lines</td></tr>" >> $html_out
	echo "  <tr><td> --> " `head -1 $file` "</td></tr>" >> $html_out
done
echo "	</tbody></table>" >> $html_out
echo "</body>" >> $html_out
echo "</html>" >> $html_out

## ----------
## creating galaxy history outputs
## ----------
#cp 'index.html' $html_out # this is the overview of samples html
cp $bam_base'.html' $out_path/'out.html' # this is the sample html
cp $bam_base'.falco.vcf' $vcf_out
cp $bam_base'.qc.ann.qual.txt' $qc_ann_qual_out
cp $bam_base'.qc2.ann.txt' $qc2_ann_txt_out
cp $bam_base'.qc.targets.txt' $qc_targets_txt_out

## ----------
## copy files to keep to output path
## ----------
#cp -r ./$bam_base/*png $out_path/$bam_base/
#cp -r ./* $out_path
cp *.vcf $out_path; 
#cp *.txt $out_path; 
cp *_std* $out_path

## ----------
echo "END falco sh"
exit 0
