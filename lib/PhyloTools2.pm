# Pablo Vinuesa, http://www.ccg.unam.mx/~vinuesa
# 2012 CCG/UNAM, Mexico, 
# Modulo de ejemplo del curso "Introduccion a la programacion en Perl para bioinformatica"

package PhyloTools2;
use strict;
use warnings;

our $VERSION = '0.2'; # v0.2 17 Nov. 2018
our(@ISA, @EXPORT);
use Exporter;

@ISA    = qw(Exporter);                  # activamos el proceso de exportacion
@EXPORT = qw( run_muscle run_clustalo);  # exportamos automaticamente las subrutinas indicadas

#use Exporter 'import';                       # activamos el proceso de exportacion
#our @EXPORT, qw(run_muscle run_clustalo);    # exportamos la subrutina run_muscle

use File::Basename;
use Carp;

#------------------------------------------------------------------------------------------------#

my $muscle_bin = '/usr/bin/muscle';
my $clustalo_bin = '/usr/local/bin/clustalo';

my @binaries = ($muscle_bin, $clustalo_bin);

foreach my $bin (@binaries)
{
  check_is_installed($bin);
}


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

sub run_muscle   
{
    my($infile, $clean, $verbosity) = @_;

    my $filename = basename($infile);
    my @file_name_parts;
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

sub run_clustalo   
{
   my ( $infile ) = @_;

   my $filename = basename($infile);
   my ( $file_basename, $file_ext ) = split(/\./,$filename);
  
   my $outfile  = $file_basename . "_cluoAln.$file_ext"; 

   # run clustalo   
   print "# sub run_clustalo is running $clustalo_bin -i $infile -o $outfile\n";
   system(" $clustalo_bin -i $infile -o $outfile ");   
   
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



1;



