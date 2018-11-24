# Presentación: perl4bioinfo, Perl para bioinform&aacute;tica - UNAM, semestre 2019-1

## Tema 14: Introducci&oacute;n al uso de m&oacute;dulos de Perl

### Presentación

Este respositorio contiene el material didáctico asocialdo al **tema 14: Modulos** del **Curso Fundamental de Posgrado** 
impartido en el marco de los **Programas de Posgrado en Ciencias Bioquímicas y Ciencias Biomédicas**
de la Universidad Nacional Autómoma de México ([UNAM](http://www.unam.mx/)), semestre 2019-1, 
impartido en el Centro de Ciencias Genómicas ([CCG](http://www.ccg.unam.mx/)), Cuernavaca, 
Morelos, México.

### Licencia y términos de uso

El material didáctico y código asociados a este tema del [curso_perl4bioinfo](https://github.com/vinuesa/curso_perl4bioinfo) lo distribuyo p&uacute;blicamente a trav&eacute;s de este [repositorio GitHub](https://github.com/vinuesa/curso_perl4bioinfo) bajo la [**Licencia No Comercial Creative Commons 4.0**](https://creativecommons.org/licenses/by-nc/4.0/) 

[**This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 Licencse**](http://creativecommons.org/licenses/by-nc/4.0/)

![CC BY-NC 4.0 license](docs/perl4bioinfo/pics/CC_BY-NC_4.0_88x31.png)

### Acceso a las presentaciones, binarios y datos asociados

- En formato [HTML](https://vinuesa.github.io/curso_perl4bioinfo/perl4bioinfo/)

- Formato [presentación-Rpubs](https://vinuesa.github.io/curso_perl4bioinfo/perl4bioinfo/Rpubs/)

- Los binarios de clustalo, muscle, FastTree y phyml los encuentras en https://github.com/vinuesa/curso_perl4bioinfo/tree/master/bin

- las secuencias en https://github.com/vinuesa/curso_perl4bioinfo/tree/master/docs/perl4bioinfo/seq

### Clonaci&oacute;n del repositorio

Si tienes instalado [git](https://git-scm.com/) en tu computadora, puedes clonar el 
repositorio con el comando:

<pre style="background: whitesmoke">
git clone https://github.com/vinuesa/curso_perl4bioinfo.git
</pre>

Para actualizar los contenidos de este repositorio en tu máquina, ve al
directorio en el que clonaste el repositorio y ejecuta un $git\ pull$

<pre style="background: whitesmoke">
cd /path/GithubRepo/curso_perl4bioinfo
git pull
</pre>

Puedes instalar $git$ fácilmente en Ubuntu usando:
<pre style="background: whitesmoke">
sudo apt install git
</pre>

Alternativamente, puedes descargar el archivo [master.zip](https://github.com/vinuesa/get_phylomarkers/archive/master.zip)

#### Módulos del CPAN, requeridos para este tema

- $Statistics::Descriptive$
- $Statistics::Distributions$
- $Bio::Perl$
- $cpanm$

En Ubuntu, los puedes instalar usando:
<pre style="background: whitesmoke">
sudo apt install perldoc cpanminus bioperl libstatistics-descriptive-perl libstatistics-distributions-perl
</pre>

Estos módulos están en el directorio $lib$ del repositorio GitHub.

#### binarios a instalar, usando apt (distribuciones Debian, como Ubuntu)
<pre style="background: whitesmoke">
sudo apt install muscle clustalo fasttree phyml
</pre>

Estos binarios (Linux, 64bit) están en el directorio $bin$ del repositorio GitHub.

