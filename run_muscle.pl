#!/usr/bin/env perl

# 1. load modules and pragmas
use strict;
use warnings;
use Carp;
use Cwd;
use File::Basename;

my $cwd = getcwd;
my $host = `hostname`;

# >>> Note the use of a BEGIN{ } block, to set the path in @INC at compile time!
if ($host eq "Tenerife")
{ 
   # BEGIN { unshift @INC, '/export/data/dbox/Dropbox/Cursos/perl4bioinfo/my_code' ;} 
   use lib qw(/export/data/dbox/Dropbox/Cursos/perl4bioinfo/my_code) ;
}
else
{
   # >>> EDIT THIS LINE TO SET THE CORRECT PATH TO THE *pm FILES <<<
   # BEGIN { unshift @INC, '/home/vinuesa/Dropbox/Cursos/perl4bioinfo/my_code' ;}
   use lib qw(/home/vinuesa/Dropbox/Cursos/perl4bioinfo/my_code) ;
}

use PhyloTools;

my $VERSION = 0.2; # v0.2_16Oct2018
my $progname = basename($0);

print_help() unless @ARGV;

my $fasta_file = shift @ARGV;

croak "\n# ERROR: no fasta file $fasta_file in dir $cwd!\n\n" if ! -s $fasta_file;

# run clustalo
print "# will run muscle to align file: $fasta_file\n";
PhyloTools::run_muscle($fasta_file, 1);

#-----------------------------------------------------------
sub print_help
{
  print <<"EOF";
  
  USAGE:
    $progname version $VERSION requires a fasta file name as a single argument on the command line 
     
  AIM:
    will run muscle to align the provided fasta file
    
  CWD:
    $cwd    
 
EOF
   exit 0
}
