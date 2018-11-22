#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;
use Bio::SeqIO; 

my $progname = basename($0);

my $VERSION = 0.2; # November 21st, 2013

# get command-line arguments, or die with a usage statement

my $usage =<<"EOF";

USAGE:
$progname v.$VERSION infile infileformat outfile outfileformat

accepted formats are:

   Fasta       FASTA format
   EMBL        EMBL format
   GenBank     GenBank format
   swiss       Swissprot format
   PIR         Protein Information Resource format
   GCG         GCG format
   raw         Raw format (one sequence per line, no ID)
   ace         ACeDB sequence format
   game        GAME XML format
   phd         phred output
   qual        Quality values (get a sequence of quality scores)
   Fastq       Fastq format
   SCF         SCF tracefile format
   ABI         ABI tracefile format
   ALF         ALF tracefile format
   CTF         CTF tracefile format
   ZTR         ZTR tracefile format
   PLN         Staden plain tracefile format
   EXP         Staden tagged experiment tracefile format

EOF

my $infile        = shift or die $usage;
my $infileformat  = shift or die $usage;
my $outfile       = shift or die $usage;
my $outfileformat = shift or die $usage;

 
# create one SeqIO object to read in,and another to write out
my $in = Bio::SeqIO->new(
                             -file   => "<$infile",
                             -format => $infileformat,
                             );
my $out = Bio::SeqIO->new(
                              -file   => ">$outfile",
                              -format => $outfileformat,
                              );
 
# write each entry in the input file to the output file
while (my $seq = $in->next_seq) {
    $out->write_seq($seq);
}


