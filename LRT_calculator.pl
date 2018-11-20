#!/usr/bin/env perl

#: SCRIPT: LRT_calculator.pl
#: Author: Pablo Vinuesa, Center for Genome Sciences, UNAM, Mexico
#:         http://www.ccg.unam.mx/~vinuesa/
#: Project start: Nov 2018

#: AIM:
#: LRT_calculator.pl uses as input the -lnL scores of the nested H1 and H0 models under competition   
#: to calculate the corresponding LRT statistic; LRT = 2(lnL H1 - lnL H0)

#: Dependencies: NONE: uses only standard perl modules.           

use strict;
use warnings;

use Getopt::Std;
use File::Basename;
use Statistics::Distributions;

my $progname = basename($0); # LRT_calculator.pl
my $VERSION  = 0.1;          # 19Nov18
                   
#----------------#
#>>> getopts <<< #
#----------------#

my $a = 0.05; # set default alpha
my (%opts,$lnL0,$lnL1,$df);

getopts('l:L:d:a:h', \%opts);

if(($opts{'h'})||(scalar(keys(%opts))==0)) 
{ 
   print_help();
}

if(defined($opts{'h'})){ print_help(); }

if(defined($opts{'l'})){ $lnL0 = $opts{'l'}; }
else{ die "ERROR: no lnL score for the null hypothesis (lnL0) provided\n\n"; }

if(defined($opts{'L'})){ $lnL1 = $opts{'L'}; }
else{ die "ERROR: no lnL score for the alternate hypothesis (lnL1) provided\n\n"; }

if(defined($opts{'d'})){ $df = $opts{'d'}; }
else{ die "ERROR: no degrees of freedom (df) provided\n\n"; }

if(defined($opts{'a'})){ $a = $opts{'a'}; }

print STDOUT << "SETTINGS";
 $progname v.$VERSION running with the following parameters:
    
    lnL0=$lnL0, lnL1=$lnL1, df=$df, q=$a

SETTINGS


#--------------------#
#>>> SUBROUTINES <<< #
#--------------------#

sub LRT_significance_calculator
{
   my ( $lnL0, $lnL1, $df, $a ) = @_;
   
   my $LRT = 2*( $lnL1 - $lnL0 );
   my $qchisq=Statistics::Distributions::chisqrdistr($df,$a);  
   my $pchisq=Statistics::Distributions::chisqrprob($df,$LRT);

   print STDOUT "\n\tLRT=$LRT | Chi-squared-crit-val (df=$df; q=$a) = $qchisq | p-val=$pchisq\n\n";
   
   return($LRT,$pchisq,$qchisq);
}
#-------------------------------------------------------------------------------

sub print_help
{
   print STDOUT << "HELP";

     $progname vers. $VERSION usage [options]:
	  -h  this help message
	  -l  lnL0    (required)
	  -L  lnL1    (required)
	  -d  df      (required)
	  -a  alpha   (optional, default:$a)

  AIM:  
    $progname uses as input the -lnL scores of a pair of nested H1 and H0 models  
       to calculate the corresponding LRT statistic [LRT = 2(lnL H1 - lnL H0)],
        and compute its significance at a user-defined alpha (critical value).
	      
  USAGE EXAMPLE: 
    $progname -l -19955.541 -L -19953.1245 -d 3
    $progname -l -19955.541 -L -19950.1245 -d 3
	      
HELP
	
    exit; 

}
#-------------------------------------------------------------------------------

#------------------#
#>>> MAIN CODE <<< #
#------------------#
my ($LRT,$pchisq,$qchisq)=LRT_significance_calculator($lnL0, $lnL1, $df, $a);

if ($pchisq <= $a){ print ">>> Significant ChiSq test! pchisq($pchisq) < alpha($a); LRT($LRT) > crit.val($qchisq) ==> reject the null model! \n\n"}
else{ print ">>>Non-significant ChiSq test! pchisq($pchisq) > alpha($a); LRT($LRT) <= crit.val($qchisq) ==> cannot reject the null model!\n\n"}


