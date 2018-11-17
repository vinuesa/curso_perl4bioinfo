#!/usr/bin/env perl

use strict;
use warnings;

my $host = `hostname`;

# programa: paquetes2.pl
# El concepto de paquetes como divisores del espacio de nombres para evitar colisiones entre simbolos.
# Importanmos simbolos desde dos paquetes externos usando la directiva 'use paquete;'.
# Estos paquetes estan guardados en los archivos Seq1.pm y Seq2.pm, y por tanto representan modulos
# (aunque todavia muy primitivos y poco funcionales, ...)

if ($host eq "Tenerife")
{ 
   use lib qw(/export/data/dbox/Dropbox/Cursos/perl4bioinfo/my_code);
}
else
{
   # >>> EDITEN ESTA LINEA PARA APUNTAR AL PATH CORRECTO 
   #       EN EL QUE SE ENCUENTRAN LOS ARCHIVOS '*pm'    <<<
   use lib qw(/home/vinuesa/Dropbox/Cursos/perl4bioinfo/my_code);
}

use Seq1;
use Seq2;

my $secuencia = 'MVLLIATG';

# imprimimos los valores de las 3 variables escalares secuencia
print "\n\tmain es: $secuencia"
     ."\n\tSeq1 es: $Seq1::secuencia"
     ."\n\tSeq2 es: $Seq2::secuencia\n\n";
