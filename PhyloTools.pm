# Pablo Vinuesa, http://www.ccg.unam.mx/~vinuesa
# 2018 CCG/UNAM, Mexico, 
# Modulo de ejemplo escrito para el curso "Introduccion a la programacion en Perl para bioinformatica"
# http://www.ccg.unam.mx/~vinuesa/perl4bioinfo/
# el codigo y tutorial estan disponibles en: https://github.com/vinuesa/curso_perl4bioinfo

package PhyloTools;
use strict;
use warnings;

use File::Basename;
use Carp;
use Bio::AlignIO;
use Statistics::Distributions;

our(@ISA, @EXPORT); # our($VAR1, @ARR1 ...) are package global symbols!
use Exporter;

@ISA       = qw(Exporter);                            # activamos el mecanismo de exportacion
@EXPORT_OK = qw( run_muscle run_clustalo run_FastTree
              convert_aln_format LRT_significance_calculator
	      compute_pwAIC);                         # exportamos las subrutinas indicadas

# >>> Edit as required for your system <<< #
my $muscle_bin   = '/usr/bin/muscle';
my $clustalo_bin = '/usr/local/bin/clustalo';
my $phyml_bin    = '/usr/local/bin/phyml';
my $FastTree_bin = '/usr/local/biotools/bin/FastTree';
my @binaries = ($muscle_bin, $clustalo_bin, $FastTree_bin, $phyml_bin);

foreach my $bin (@binaries)
{
  check_is_installed($bin);
}

=head1 NAME

PhyloTools

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02'; # v0.02_16Oct2018

=head1 SYNOPSIS
 In the calling script use:

 use lib '/path/to/module/'; # <<< Set propperly for your system!
 use PhyloTools qw(run_clustalo run_muscle run_FastTree run_phyml
		  convert_aln_format chi_square_test compute_pwAIC);

 my $mus_aln  = run_muscle($fasta_file2align, 1, 0); 
 my $cluo_aln = run_clustalo($fasta_file2align); 
 
 See the documentation for each soubroutine below, for the usage details

=cut

=head1 DESCRIPTION

This module currently exports a series of subroutines to perform basic phylogenetic analysis,
starting from multiple sequence alignment, format conversion and AIC or LRT-based model selection.
	      
It was written as a teaching aid for the course "Introduccion a la programacion en Perl para Bioinformatica",
taught at the Universidad Nacional Autonoma de Mexico for students in the PhD Programs in Biochemistry and Biomedical Sciences,
during the semester 2019-1. http://www.ccg.unam.mx/~vinuesa/perl4bioinfo/

=cut

=head1 AVAILABILITY

 The code is freely available on GitHub under the GPLv3 at:
 https://github.com/vinuesa/curso_perl4bioinfo

=cut

=head1 EXTERNAL DEPENDENCIES AND SETUP

 The module requires that muscle, clustalo and FastTree are installed. 
 Set the global variables $muscle_bin, $clustalo_bin and $FastTree_bin to the proper PATH. 

 The muscle source code or pre-compiled binaries can be freely downloaded from 
 Robert Edgar's Bioinformatics Software website at http://www.drive5.com/muscle/downloads.htm

 The clustalo source code or pre-compiled binaries can be freely downloaded from
 http://www.clustal.org/omega/

 The FastTree source code and pre-compiled binaries can be freely downloaded from
 http://www.microbesonline.org/fasttree/

 The PhyML source code is available from: https://github.com/stephaneguindon/phyml/releases
 The PhyML binaries are available from: http://www.atgc-montpellier.fr/phyml/versions.php
 
 You will need to set up the correct PATHs for each binary in the head section of this module:
 
 # >>> Edit as required for your system <<< #
   my $muscle_bin   = '/usr/bin/muscle';
   my $clustalo_bin = '/usr/local/bin/clustalo';
   my $phyml_bin    = '/usr/local/bin/phyml';
   my $FastTree_bin = '/usr/local/biotools/bin/FastTree';

=cut

=head1 EXPORT

 Currently exports the following subroutines/functions: 

 run_muscle and run_clustalo for multiple sequence alignment;
 run_FastTree and run_phyml for maximum-likelihood phylogeny inference
 convert_aln_format, chi_square_test and compute_pwAIC for those common tasks

=cut

=head1 SUBROUTINES

=head2 check_is_installed

 This function makes sure that external dependencies, such as software binaries,
 are properly defined for the module to be functional. This sub runs automatically
 and only reports an error message if a required binary is missing.

=cut
  
#--------------------------------------------------------------------------------------
#---------------------------------- SUBROUTINES ---------------------------------------
#--------------------------------------------------------------------------------------

sub check_is_installed
{
   my @binaries = @_;
   foreach my $bin (@binaries)
   {
       if( ! -x "$bin")
       {
          croak "\n#ERROR! $bin is not installed. Please install or check path setting\n\tExiting now!\n";
       }
   }
}
#--------------------------------------------------------------------------------------

=head2 function run_muscle

  This function accetps up to three arguments:
  1) name of the fasta file to be aligned (required)
  2) clean flag <0|1>, to keep or remove intermediary alignments resulting from refinement rounds 1 and 2 (optional)
  3) verbosity flag <0|1>, controls the level of progress information printed to screen (optional)

=cut

sub run_muscle   
{
   my($infile, $clean, $verbosity) = @_;
   my $filename = basename($infile);
   my @file_name_parts;
   my( $file_basename, $file_ext) = split(/\./,$filename);

   my $tmpfile1 = $file_basename . "_tmp1.mus";
   my $tmpfile2 = $file_basename . "_tmp2.mus";
   my $outfile  = $file_basename . "_aln.$file_ext"; 

   # run muscle with x2 refinement rounds after the primary alignment; note, -stable is not available anymore in muscle 3.8.31   
   print "# &run_muscle is running $muscle_bin < $infile > $tmpfile1 -quiet ...\n" if $verbosity ;
   system(" $muscle_bin < $infile > $tmpfile1 -quiet ");
   system(" $muscle_bin < $tmpfile1 > $tmpfile2 -refine -quiet ");
   system(" $muscle_bin < $tmpfile2 > $outfile -refine -quiet ");
   
   # clean file
   if($clean==1)
   { 
     print "# will remove tmp files $tmpfile1, $tmpfile2\n" if $verbosity ;
     unlink $tmpfile1, $tmpfile2; 
   }

   # check the output file is there
   if(! -s $outfile)
   { 
     print "# ERROR; outfile $outfile is empty\n";
     return; 
   }
   else
   { 
     print "# &run_muscle returned aligned outfile $outfile\n";
      return $outfile; 
   }
}
#--------------------------------------------------------------------------------------

=head2 function run_clustalo

  This function currently accetps a single argument:
  1) name of the fasta file to be aligned (required)
  
=cut

sub run_clustalo   
{
   my ( $infile ) = @_;
   my $filename = basename($infile);
   my ( $file_basename, $file_ext ) = split(/\./,$filename);
   my $outfile  = $file_basename . "_cluoAln.$file_ext"; 

   # run clustalo   
   print "# &run_clustalo is running $clustalo_bin -i $infile -o $outfile --force\n";
   system(" $clustalo_bin -i $infile -o $outfile --force ");   
   
   # check the output file is there
   if(! -s $outfile)
   { 
     print "# ERROR; outfile $outfile is empty\n";
     return; 
   }
   else
   { 
     print "# &run_clustalo returned aligned outfile $outfile\n";
      return $outfile; 
   }
}
#--------------------------------------------------------------------------------------


=head2 convert_aln_format

  This function uses the Bio::AlignIO from the Bio::Perl suite
  and is used to convert between alignment formats
  
  It takes 4 arguments, in the following order
  1) name of the input alignment file to be converted
  2) name of the input alignment's format
  3) name of the output file format
  4) name of the output file's format

=cut

sub convert_aln_format
{
    my ($infile, $infileformat, $outfile, $outfileformat) = @_;

    my $in = Bio::AlignIO->new(
                                 -file   => "<$infile",
                                 -format => $infileformat,
                             );
    my $out = Bio::AlignIO->new(
                                  -file   => ">$outfile",
                                  -format => $outfileformat,
                                  );

    # write each entry in the input file to the output file
    while (my $aln = $in->next_aln) {
        $out->write_aln($aln);
    }
}
#--------------------------------------------------------------------------------------

=head2 function run_phyml

  This function currently accetps three arguments:
  1) alignment file in phylip format (required)
  2) sequence type <aa|nt>
  3) base model name 
       aa: (LG | WAG | JTT | MtREV | Dayhoff | DCMut | RtREV | CpREV | VT | AB |
		 Blosum62 | MtMam | MtArt | HIVw |  HIVb | custom)
       nt: (JC69 | K80 | F81 | F84 | HKY85 | TN93 | GTR | custom [012345 corresponds to GTR]
  
=cut

sub run_phyml
{
   my ( $infile, $seq_type, $base_model ) = @_;
   my $filename = basename($infile);
   my ( $file_basename, $file_ext ) = split(/\./,$filename);
   my $outfile  = $file_basename . "phy_phyml_tree"; 
   # run phyml   
   if ($seq_type eq "aa")
   {
       print "# &run_phyml is running: $phyml_bin -i $infile -d $seq_type -m $base_model -a e -o tlr -s BEST\n";
       system(" $phyml_bin -i $infile -d $seq_type -m $base_model -c 4 -a e -o lrt -s BEST ");   
      
   }
   else
   {
      print "# &run_phyml is running: $phyml_bin -i $infile -d $seq_type -m $base_model -a e -o tlr -s BEST\n";
      system(" $phyml_bin -i $infile -d $seq_type -m $base_model -c 4 -a e -o lrt -s BEST ");   
   } 
   
   # check the output file is there
   if(! -s $outfile)
   { 
      print "# ERROR; outfile $outfile is empty\n";
      return; 
   }
   else
   { 
      print "# &run_clustalo returned aligned outfile $outfile\n";
      return $outfile; 
   }
}
#--------------------------------------------------------------------------------------

=head2 function run_FastTree

  This function currently accetps two arguments:
  1) alignment file in FASTA format (required)
  2) sequence type <aa|nt> (required)
  
=cut


sub run_FastTree
{
   my ( $infile, $seq_type) = @_;
   my $outfile = '';
   my $filename = basename($infile);
   my ( $file_basename, $file_ext ) = split(/\./,$filename);
  
   # run phyml   
   if ($seq_type eq "aa")
   {
          $outfile  = $file_basename . "_FTLGG.ph"; 

       print "# sub run_FastTree is running: $FastTree_bin -lg -gamma -quiet < $infile > $outfile\n";
       system(" $FastTree_bin -lg -gamma -quiet < $infile > $outfile ");   
   }
   else
   {
       $outfile  = $file_basename . "_FTGTRG.ph"; 
       print "# sub run_FastTree is running: $FastTree_bin -nt -gtr -gamma -quiet < $infile > $outfile\n";
       system(" $FastTree_bin -nt -gtr -gamma -quiet < $infile > $outfile ");   
   } 
   
   # check the output file is there
   if(! -s $outfile)
   { 
     print "# ERROR; outfile $outfile is empty\n";
     return; 
   }
   else
   { 
     print "# run_clustalo() returned aligned outfile $outfile\n";
      return $outfile; 
   }
}
#--------------------------------------------------------------------------------------

=head2 function chi_square_test

  This function computes the LRT, Chi-squared critical value and associated p-value 
       based on the log-likelihood scores of two competing and nested DNA substitution models

  It currently accetps four arguments:
  1) lnL score for the alternative hypothesis H1 (lnL1 (the model with more parameters)
  2) lnL score for the null hypothesis (the nested model with a constrained/fixed parameter)
  3) degrees of freedom (df), corresponding to the difference in free parameters between H1 and H0
  4) percentile = $q level to be considered to compute the Chi-squared critical value
  
=cut

sub LRT_significance_calculator
{
   my ( $lnL0, $lnL1, $df, $a ) = @_;
   
   my $LRT = 2*( $lnL1 - $lnL0 );
   my $qchisq=Statistics::Distributions::chisqrdistr($df,$a);  
   my $pchisq=Statistics::Distributions::chisqrprob($df,$LRT);

   print STDOUT "\n\tLRT=$LRT | Chi-squared-crit-val (df=$df; q=$a) = $qchisq | p-val=$pchisq\n\n";
   
   return($LRT,$pchisq,$qchisq);
}
#--------------------------------------------------------------------------------------

=head2 function compute_AIC
  
  This simple function uses the Akaike information criterion, 
  based on the log-likelihood scores of a set of 2 competing models 
  to select the best one. Note: these models do not need to be nested!
  
  # Calculate AIC:
      AIC = -2lnL + 2K
      L: max likelihood, K: number of free parameters

  compute_AIC currently accetps 4 arguments:
  1) lnL score for the model with the highest lnL (lnL1) 
  2) lnL score for model 2, with lower lnL score (lnL2) 
  3) number of free parameters for model 1 (K1)
  4) number of free parameters for model 2 (K2)
  
=cut

sub compute_pwAIC
{
   my ( $lnL1, $lnL2, $K1, $K2 ) = @_;
   
   my $AIC1 = (((-2.0)*($lnL1)) + (2.0*($K1))); 
   my $AIC2 = (((-2.0)*($lnL2)) + (2.0*($K2)));
   my $delta_i = ($AIC1 - $AIC2);
   
   print STDOUT "\n\tAIC1=$AIC1, K1=$K1| AIC2=$AIC2, K2=$K2| delta_i=$delta_i\n\n";
   
   return($delta_i);
}

#--------------------------------------------------------------------------------------

=head1 BUGS

None known. Please report to the author any bugs you may encounter.

=head1 AUTHOR

Pablo Vinuesa, C<< <vinuesa[at]ccg.unam.mx> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2018 Pablo Vinuesa. All rights reserved. This program is free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

1; # <<< don't forget to exit module returning a TRUE value!!!




