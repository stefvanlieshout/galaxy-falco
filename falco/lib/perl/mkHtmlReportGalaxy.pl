#!/usr/bin/perl -w

use strict;
use Cwd;
use Spreadsheet::WriteExcel;

$| = 1;
my $sample = shift || die "Missing input\n";
my $qc_targets_txt = shift || die "Missing input\n";
my $dir = shift || "./";
my $outdir = shift || "./";
my $pat = shift || "";
my $cwd = cwd();
(my $runName = $cwd) =~ s/^.*\/(.*?)$/$1/;

# QC
# Results
my @samples = ();
my $htmlHead = qq(
<!DOCTYPE html>
<html>
<head>
<style type="text/css">
body {font-family:arial;}
table {font-family:arial;border-collapse: collapse; font-size: smaller;}
th {border: 1px solid gray; padding: 5px;}
td {border: 1px solid gray; padding: 5px; text-align: right;}
</style>
</head>
<body>
);
	
my %link = ();
my $excelBook0 = Spreadsheet::WriteExcel->new("$outdir/runQC.xls");
my $excel0 = $excelBook0->add_worksheet("table1");
my $excel0Ref = [[qw/sampleName runName totalReads pct100 ntbGenes/]];

print STDERR "Processing $sample\n";
#	next if ($sample =~ /R[12]/);

my $readCnt = 0;
my $amp100 = 0;
my %ntbGenes = ();

open OUT, ">$outdir/$sample.html";
open OUT2, ">$outdir/$sample.tsv";
my $excelBook = Spreadsheet::WriteExcel->new("$outdir/$sample.xls");
my $excel1 = $excelBook->add_worksheet("table1");
my $excel2 = $excelBook->add_worksheet("table2");
print OUT $htmlHead;
my %QC = ();
open QC, "<$qc_targets_txt" or die "Unable to open qc_targets_txt\n";
readline QC;
print STDERR "Reading in $qc_targets_txt\n";
while (<QC>) {
	chomp;
	my @row = split(/\t/, $_);
	my @id = split(/[\_\.\-:]/, $row[0]);
	$row[-1] = 0 if ($row[-1] eq "NA");
	$readCnt += $row[-1]; # DP
	if ($#id != 10) {
		$id[0] =~ /(\D+)(\d+)/;
		$id[0] = $2;
		unshift @id, $1;
	}

	if ($row[-1] >= 100) {
		$amp100++
	}
	else {
		$ntbGenes{$row[0]}{dp} = $row[-1];
		$ntbGenes{$row[0]}{id} = [@id];
	}

	$QC{$row[0]}{QC} = [@id, @row];# if ($id[0]);
	foreach my $c ($row[4] .. $row[5]) {
		$link{$id[-3] . ":" . $c}{$row[0]} = "Assay";
	}
	foreach my $c ($row[2] .. $row[4], $row[5] .. $row[3]) {
		$link{$id[-3] . ":" . $c}{$row[0]} = "LSO";
	}	
}
close QC;

open RES, "<$dir/$sample.res.filtered.tsv" or die "Unable to open $dir/$sample\n";
my %uniq = ();
my $colCnt = 0;
my $resHead = readline(RES);
chomp $resHead;
$resHead =~ s/^#//;
$resHead =~ s/\s+$//;
my %resCol = map { $_ => $colCnt++ } split(/\t/, $resHead);
my @keyColsN = qw/QUAL Gene_Name Codon_Change Amino_Acid_change vaf DP AD Tag CHROM POS ID REF ALT Context Effect_Impact Functional_Class Amino_Acid_length Gene_Coding Transcript_ID Exon_Rank/;	
#	my @keyColsN = qw/CHROM POS ID REF ALT QUAL DP AD vaf Context Effect_Impact Functional_Class Codon_Change Amino_Acid_change Amino_Acid_length Gene_Name Coding Transcript Exon Tag/;	
my @keyColsI = map { $resCol{$_} } @keyColsN;
foreach my $i (0 .. $#keyColsN) {
	print STDERR join(":", $i, $keyColsN[$i], $keyColsI[$i]) . "\n";
}

print STDERR "Processing results\n";
while (<RES>) {
	chomp;
	my @row = split(/\t/, $_);
	my $cpos = join(":", @row[0, 1]);
	if (exists $link{$cpos}) {
#			my $key = join(":", @row[0 .. 4,6, 9,10,11,12,14 .. 21]);
		my $key = join(":", @row[@keyColsI]);
		#print STDERR join(":", @keyColsI) . "\n";
#			print STDERR join(":", @row) . "\n"; sleep 1;
		if (not exists($uniq{$key})) {
			foreach my $locus (keys(%{$link{$cpos}})) {
				next if ($link{$cpos}{$locus} eq "LSO");
				push @{$QC{$locus}{RES}}, [@row, $link{$cpos}{$locus}];
		#		print STDERR "Adding $key to $locus\n\n"; #sleep 1;
			}
			$uniq{$key} = 0;
		}
		else {
		#	print STDERR $key . " : Exists\n\n"; #sleep 1;
		}
	}
}
close RES;

## Rplots that are not self-explanatory enough
#print OUT "<img src=\"$sample/$sample.vaf.png\">";
#print OUT "<img src=\"$sample/$sample.raf.png\">";
#print OUT "<img src=\"$sample/$sample.snv-q.png\">";
#print OUT "<img src=\"$sample/$sample.snv-q-zoom.png\">";
#print OUT "<img src=\"$sample/$sample.ins-q.png\">";
#print OUT "<img src=\"$sample/$sample.del-q.png\">";

print OUT "<img src=\"$sample/$sample.amp-dp.png\">";
#print OUT "<img src=\"$sample/$sample.heat.png\">";
#print OUT "<img src=\"$sample/$sample.bias.png\">";
#print OUT "<img src=\"$sample/$sample.biasheat.png\">";
#print OUT "<img src=\"$sample/$sample.vafcut.png\">";
print OUT "<table border=1><tr><th>Download:</th><th><a href=\"$sample.tsv\">TSV</a></th>";
print OUT "<th><a href=\"$sample.xls\">XLS</a></th></table>";
print OUT "<table border=1>\n";
#	my @colnames = qw/depth chr pos id ref var qual DP AD vaf context impact effectClass codonChange AAChange RefSeqLength geneName RefSeqClass RefSeqID Exon Tag/;
my @colnames = ("depth", @keyColsN);
print OUT "<tr>" . join("", map { "<th>$_</th>" } ("Amplicon", "c","c2", "b", @colnames)) . "</tr>";
print OUT2 join("\t", "Amplicon", @colnames) . "\n";
my $excelAref = [["Amplicon", @colnames]];
my $excelAref2 = [[qw/gene exon protein vaf func depth /]];
my %rescnt = ();
foreach my $locus (sort keys(%QC)) {
#	my @targets = keys(%{$QC{$locus}{QC}});
#		print OUT "</td>";
	my $nres = 1;
	$nres = scalar(@{$QC{$locus}{RES}}) if ($QC{$locus}{RES});
	
	print OUT "<tr><td rowspan=\"$nres\">$locus</td>\n";
	print OUT "<td rowspan=\"$nres\"><a href=\"$sample/$sample.$locus.cov.png\">c</a></td>\n";
	print OUT "<td rowspan=\"$nres\"><a href=\"$sample/$sample.$locus.cov2.png\">c2</a></td>\n";
	print OUT "<td rowspan=\"$nres\"><a href=\"$sample/$sample.$locus.bias.png\">b</a></td>\n";
	print OUT "<td rowspan=\"$nres\">$QC{$locus}{QC}->[-1]</td>\n"; #<td rowspan=\"$nres\">";
            
	foreach my $res (@{$QC{$locus}{RES}}) {
		$res = [map {$_ || ""} @$res];
		print OUT "<td>\n";
		print OUT join("</td><td>\n", @{$res}[@keyColsI]);
		print OUT "</td></tr><tr>\n";
		print OUT2 join("\t", $locus, $QC{$locus}{QC}->[-1], @{$res}[@keyColsI]) . "\n";
		push @$excelAref, [$locus, $QC{$locus}{QC}->[-1], @{$res}[@keyColsI]];
		
# qw/QUAL Gene_Name Codon_Change Amino_Acid_change vaf DP AD Tag CHROM POS ID REF ALT Context Effect_Impact Functional_Class Amino_Acid_length Coding Transcript Exon/;	
		push @$excelAref2, [map {$_ || "NA"} @{$res}[map { $resCol{$_} } (qw/Gene_Name Exon_Rank Amino_Acid_change vaf Functional_Class/)], $QC{$locus}{QC}->[-1]];
#			push @$excelAref2, [map {$_ || "NA"} @{$res}[[qw/Gene_Name Exon_Rank Cdna_change Amino_Acid_change vaf Functional_Class/]], $QC{$locus}{QC}->[-1]];
		my $pl = $res->[$keyColsI[7]];
		my $ref = $res->[$keyColsI[11]];
		my $var = $res->[$keyColsI[12]];
#			print STDERR "$pl $ref $var\n"; sleep 1;
		if (length($ref) == length($var)) {
			$rescnt{$pl . "snp"}++;
		}
		else {
			$rescnt{$pl . "indel"}++;
		}
#			$rescnt++;
	}
	print STDERR $locus . ":" . $nres . "\n";
	print STDERR $locus . ":" . join("-", @{$QC{$locus}{RES}}) . "\n";
	if (scalar(@{$QC{$locus}{RES}}) == 0) { #$nres == 0) {
		print OUT2 join("\t", $locus, $QC{$locus}{QC}->[-1], ("-") x scalar(@keyColsI)) . "\n";
		push @$excelAref, [$locus, $QC{$locus}{QC}->[-1], ("-") x scalar(@keyColsI)];
	}
	print OUT "</tr>\n";
}
print OUT "</table>\n";
print OUT "</body></html>\n";
close OUT;
close OUT2;
$excel1->write_col(0,0, $excelAref);
$excel2->write_col(0,0, $excelAref2);
$excelBook->close();
my @resCnt = map { $rescnt{$_} || 0 } qw/Falcosnp Falcoindel/;
my $pctGood = sprintf("%.2f", $amp100 / scalar(keys(%QC)) * 100);
my $ntbsAmps = join(",", map { s/^(.*?)\.chr.*$/$1/; $_;  } keys(%ntbGenes));
push @{$excel0Ref}, [$sample, $runName, $readCnt, $pctGood, $ntbsAmps];

$excel0->write_col(0,0, $excel0Ref);
$excelBook0->close();


