#!/usr/bin/env perl

# programa: paquetes1.pl
# El concepto de paquetes como divisores del espacio de nombres para evitar colisiones entre simbolos

# estamos en el paquete principal "main"
$secuencia = 'MVLLIATG';

# declaramos un nuevo paquete y declaramos una variable en dicho paquete
package Seq1;
$secuencia = 'AAAAAAAA';

# declaramos un segundo paquete y declaramos una variable en dicho paquete
package Seq2;
$secuencia = 'CCCCCCCC';

# regresamos al paquete main e imprimimos los valores de las 3 variables escalares secuencia
package main;

# imprimimos las secuencias, usando las variables completamente calificadas
print "\n\tmain es: $secuencia"
     ."\n\tSeq1 es: $Seq1::secuencia"
     ."\n\tSeq2 es: $Seq2::secuencia\n\n";
