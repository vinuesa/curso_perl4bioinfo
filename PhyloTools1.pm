# Pablo Vinuesa, http://www.ccg.unam.mx/~vinuesa
# 2012 CCG/UNAM, Mexico, 
# Modulo de ejemplo del curso "Introduccion a la programacion en Perl para bioinformatica"

package PhyloTools;
use strict;
use warnings;

use File::Basename;
use Carp;

my $muscle_bin = '/usr/bin/muscle';

my @binaries = ($muscle_bin);


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



1;



