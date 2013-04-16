#!usr/bin/env perl
use strict;
use warnings;

=head1 LICENSE


  Copyright (c) 1999-2013 The European Bioinformatics Institute and
  Genome Research Limited.  All rights reserved.

  This software is distributed under a modified Apache license.
  For license details, please see

    http://www.ensembl.org/info/about/code_licence.html

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <ensembl-dev@ebi.ac.uk>.

  Questions may also be sent to the Ensembl help desk at
  <helpdesk@ensembl.org>.

=head1 NAME

 bisulphite_qc.pl
  
=head1 SYNOPSIS

 bisulphite_qc.pl /path/to/bed/dnamethylationfeature_bed_file.bed
 
 Quality control check for DNAMethylationFeature bed files 

=head1 OPTIONS

perl bisulphite_qc.pl /path/to/dnamethylationfeature_bed_files/GM12878/GM12878_5MC_ENCODE_HAIB.bed

The only required argument is a DNAMethylationFeature bed file in Ensembl specific DNAMethylation bed format.
The output will be generated in the same directory in which the programme is run.

=head1 DESCRIPTION

This program computes fraction of methy-cytosines at each individual read depth between 1 and 100 and clubs everything
beyond 100 into one group.
The results are plotted into separate line charts for each cytosine context in the bed file using R. 


=head1 output

Text file for each of the cytosine contexts
R code file to generate the plots
Pdf of plots

=cut

#INPUT BED FILE
my $file = $ARGV[0];
my ( %hash, %defined_contexts );
open( FH, $file ) or die "cant open $!";
my $line;
while ( chomp( $line = <FH> ) ) {
    my ( @temp, $depth, $context );
    @temp = split( /\s+/, $line );
    ( $context, $depth ) = split "/", $temp[3];
    $defined_contexts{$context} = undef;
    $depth = "gt_100" if $depth > 100;
    $temp[4] > 0
      ? $hash{ $context . "_" . $depth }{meth}++
      : $hash{ $context . "_" . $depth }{unmeth}++;

}

close(FH);

$file = ( split "/", $file )[-1];
$file =~ s/(.*).bed$/$1/;

open( FO, ">${file}.R" );
print FO "pdf(file=\"${file}.pdf\")\n";

for my $context ( sort keys %defined_contexts )

{
    my $outfile = "${file}_$context";
    open( FHW, ">" . $outfile );

    for my $depth ( 1 .. 100 )

    {
        if (    ( defined $hash{ $context . "_" . $depth }{meth} )
            and ( defined $hash{ $context . "_" . $depth }{unmeth} ) )
        {
            print FHW "$depth\t",
              $hash{ $context . "_" . $depth }{meth} /
              ( $hash{ $context . "_" . $depth }{meth} +
                  $hash{ $context . "_" . $depth }{unmeth} ), "\n";
        }

    }
    print FHW "101\t",
      $hash{ $context . "_gt_100" }{meth} /
      ( $hash{ $context . "_gt_100" }{meth} +
          $hash{ $context . "_gt_100" }{unmeth} );

    close(FHW);

    print FO "data <- read.table(\"$outfile\",sep=\"\t\",header=F)\n";
    print FO
"plot(data,type=\"l\",col=\"blue\",axes=F,xlab=\"Read depth\", ylab=\"methyl-Cs/Covered-Cs\",main=\"$context\")\n";
    print FO "axis(2)\n";
    print FO
"axis(1,las=2,cex.axis=0.8,at=c(1,seq(5,100,by=5)),lab=c(1,seq(5,100,by=5)))\n";
    print FO "box()\n";

}

print FO "dev.off()\n";

close(FO);
system "R CMD BATCH --slave ${file}.R";
