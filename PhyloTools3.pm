# Pablo Vinuesa, http://www.ccg.unam.mx/~vinuesa
# 2018 CCG/UNAM, Mexico, 
# Modulo de ejemplo escrito para el curso "Introduccion a la programacion en Perl para bioinformatica"
# http://www.ccg.unam.mx/~vinuesa/perl4bioinfo/
# el codigo y tutorial estan disponibles en: https://github.com/vinuesa/curso_perl4bioinfo

package PhyloTools3;
use strict;
use warnings;

our $VERSION = '0.2'; # v0.2 17 Nov. 2018
our(@ISA, @EXPORT);
use Exporter;

@ISA    = qw(Exporter);                               # activamos el mecanismo de exportacion
@EXPORT = qw( run_muscle run_clustalo run_FastTree);  # exportamos las subrutinas indicadas

use File::Basename;
use Carp;

# >>> Edit as required for your system <<< #
my $muscle_bin   = '/usr/bin/muscle';
my $clustalo_bin = '/usr/local/bin/clustalo';
my $phyml_bin    = '/usr/local/bin/phyml';
my $FastTree_bin = '/usr/local/biotools/bin/FastTree';

my @binaries = ($muscle_bin, $clustalo_bin, $FastTree_bin);


foreach my $bin (@binaries)
{
  check_is_installed($bin);
}

=head1 NAME

PhyloTools3

=head1 VERSION

Version 0.02

=cut

$VERSION = '0.03'; # v0.03_23Oct2018

=head1 SYNOPSIS
In the calling script use:

 use lib '/path/to/module/';
 use PhyloTools3 qw(run_clustalo run_muscle);;

 my $mus_aln = run_muscle($fasta_file2align, 1, 0); 
 my $cluo_aln = run_clustalo($fasta_file2align); 

 See the documentation for each soubroutine below, for the usage details

=cut

=head1 DESCRIPTION

 This module currently exports a series of subroutines to perform basic phylogenetic analysis,
 starting from multiple sequence alignment.       
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
 
 You will need to set up the correct PATHs for each binary in the head section of this module:
 # >>> Edit as required for your system <<< #
   my $muscle_bin   = '/usr/bin/muscle';
   my $clustalo_bin = '/usr/local/bin/clustalo';
   my $FastTree_bin = '/usr/local/biotools/bin/FastTree';

=cut

=head1 EXPORT

Currently exports run_muscle, run_clustalo and run_FastTree.  

=head1 EXTERNAL DEPENDENCIES

 The module requires that muscle, clustalo and FastTree are installed. 
 Set the global variables $muscle_bin, $clustalo_bin and $FastTree_bin to the proper PATH. 

 The muscle source code or pre-compiled binaries can be freely downloaded from 
 Robert Edgar's Bioinformatics Software website at http://www.drive5.com/muscle/downloads.htm

 The clustalo source code or pre-compiled binaries can be freely downloaded from
 http://www.clustal.org/omega/
 
 The FastTree source code and pre-compiled binaries can be freely downloaded from
 http://www.microbesonline.org/fasttree/

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
   my( $file_basename, $file_ext) = split(/\./,$filename);

   my $tmpfile1 = $file_basename . "_tmp1.mus";
   my $tmpfile2 = $file_basename . "_tmp2.mus";
   my $outfile  = $file_basename . "_musAln.$file_ext"; 

   # run muscle with x2 refinement rounds after the primary alignment; note, -stable is not available anymore in muscle 3.8.31
   print "# sub run_muscle is running $muscle_bin < $infile > $tmpfile1 -quiet ...\n" if $verbosity ;
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
     print "# run_muscle() returned aligned outfile $outfile\n";
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
   print "# sub run_clustalo is running $clustalo_bin -i $infile -o $outfile --force\n";
   system(" $clustalo_bin -i $infile -o $outfile --force ");   
   
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
       print "# sub run_phyml is running: $phyml_bin -i $infile -d $seq_type -m $base_model -a e -o tlr -s BEST\n";
       system(" $phyml_bin -i $infile -d $seq_type -m $base_model -c 4 -a e -o lrt -s BEST ");   
      
   }
   else
   {
       print "# sub run_phyml is running: $phyml_bin -i $infile -d $seq_type -m $base_model -a e -o tlr -s BEST\n";
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
     print "# run_clustalo() returned aligned outfile $outfile\n";
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

=head1 BUGS

None known. Please report to the author any bugs you may encounter.

=head1 AUTHOR

Pablo Vinuesa, C<< <vinuesa[at]ccg.unam.mx> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2018 Pablo Vinuesa. All rights reserved.  This program is free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut

1;



