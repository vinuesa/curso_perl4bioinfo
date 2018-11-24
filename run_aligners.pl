#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename;
use Cwd;
use Carp;

my $cwd = cwd();
my $hostname = '';

if ($hostname eq "Tenerife")
{ 
   # BEGIN { unshift @INC, '/export/data/dbox/Dropbox/Cursos/perl4bioinfo/my_code' ;} 
   use lib qw(/export/data/dbox/Dropbox/Cursos/perl4bioinfo/my_code) ;
}
else
{
   # >>> EDIT THIS LINE TO SET THE CORRECT PATH TO THE *pm FILES <<<
   # BEGIN { unshift @INC, '/home/vinuesa/Dropbox/Cursos/perl4bioinfo/my_code' ;}
   use lib '/home/vinuesa/Dropbox/Cursos/perl4bioinfo/my_code' ;
}

use PhyloTools2; # use PhyloTools2 qw(run_clustalo run_muscle); # <<< if using @EXPORT_OK()

my $VERSION = 0.3; # v0.3_22Oct2018
my $progname = basename($0);

print_help() unless @ARGV;

my ($fasta_file, $alignment_algorithm) = @ARGV;

if( defined $alignment_algorithm && $alignment_algorithm ne 'clustalo' && $alignment_algorithm ne 'muscle' )
{
   croak "\n# ERROR: alignment algorithm must be either clustalo or muscle\n\n";
}

if(! defined $alignment_algorithm){ $alignment_algorithm = 'clustalo' }

croak "\n# ERROR: no file $fasta_file in dir $cwd!\n\n" if ! -s $fasta_file;

if( $alignment_algorithm eq "muscle")
{
   my $mus_aln = run_muscle($fasta_file, 1);
}
else
{
  my $cluo_aln =  run_clustalo($fasta_file);
}

#-----------------------------------------------------------
sub print_help
{
  print <<"EOF";
  
  USAGE:
    $progname version $VERSION requires 2 arguments:

    - Required
        1. A fasta file name 

    - Optional
        2. an alignment algorithm name <clustalo|muscle>
     
  AIM:
    will run clustalo or muscle to align the input fasta file
    
  CWD:
    $cwd    
 
EOF
   exit 0
}
