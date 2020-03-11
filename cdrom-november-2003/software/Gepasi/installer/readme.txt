                             Gepasi 3.30
               (Bio)chemical Kinetics Simulation Software

Copyright (C) Pedro Mendes 1989, 1992, 1993, 1996-1999, 2002. All Rights 
Reserved. Portions of the code are Copyright (C) 1985-1998 Microsoft 
Corporation. The associated program "gnuplot" is Copyright (C) 1986-1993,
1998, 1999 Thomas Williams, Colin Kelley and many others.

Information in this document is subject to change without notice and
does not represent a commitment on the part of the copyright holder or
any other parties associated with the production of this software and
documentation.


INTRODUCTION
============

Gepasi is a Microsoft Windows program intended for the simulation of the
kinetics of systems of chemical and biochemical reactions. The program
is aimed at the study and teaching of the behaviour of such systems.
Gepasi simulates the steady-state and time-course behaviour of reactions 
in several compartments of different volumes. The user supplies the 
program with information about the stoichiometric structure of the 
pathway, kinetics of each reaction, volumes of the compartments and 
initial concentration of all chemical species. The program then builds 
the differential equations that govern the behaviour of the system and 
solves them. Results are produced in a flexible way so that data can be 
imported into spreadsheets or other data processing programs. 2D and 3D 
plots can also be directly created from within the program (by using the 
package gnuplot that is distributed with Gepasi). Gepasi characterises 
the steady states that it finds using Metabolic Control Analysis and 
linear kinetic stability analysis. Gepasi has the ability of scanning 
ranges of values of the system parameters and produce a mapping of the 
behaviour of the system within these ranges. Gepasi can also use various 
nonlinear optimisation algorithms to search for maxima or minima of any 
system variable and to fit the model parameters to experimental data.

Gepasi 3 was written by Pedro Mendes at the University of Wales
Aberystwyth with funding from the Portuguese JNICT and the UK's BBSRC.


HARDWARE AND OPERATING SYSTEM REQUIREMENTS
==========================================

Gepasi 3 is a Microsoft Windows 32-bit program for computers with the 
Intel 80386 CPU (and above) running Microsoft Windows 95/98/2000 and 
Microsoft Windows NT 3.51 and above. Support for the Alpha workstations
running Windows NT has been discontinued.

Gepasi should run without problems on any computer running Microsoft
Windows 95 or above.


AVAILABILITY
============

Gepasi 3.30 is available for download from http://www.gepasi.org and a
series of sites on the Internet. The program is also available in CD-ROM 
software collections. 

INSTALATION
===========

The steps you must take to install Gepasi 3.30 depend on how you have
obtained the package. If you have installed a previous version of Gepasi
see the section below (Upgrading).

 - you obtained the file gep33xi.zip from the Internet or from a CD-ROM:

    1) unzip the contents of the file onto a temporary directory
    2) run the program setup.exe on that directory and follow the
       instructions

 - you obtained Gepasi 3.30 on floppy disks

    1) insert the floppy disk marked "Disk 1" on a floppy drive
    2) run the program setup.exe on that floppy disk and follow the
       instructions


UPGRADING
=========

There is no path for upgrade of Gepasi 3.30. If you have installed a 
previous version of Gepasi, you can install Gepasi 3.30 in the same 
directory (default is /Program Files/Gepasi) as this will overwrite the
old files. Alternatively you may want to unistall the older version of 
Gepasi prior to installing version 3.30.

DOCUMENTATION
=============

Gepasi 3 is an interactive program and its documentation is supplied in
hypertext format as a windows help file. Updates on the documentation
may become available on the Internet on the primary site for distribution 
(see above). In this package you can find a F.A.Q. file with answers to
frequently asked questions about Gepasi 3.


=====================
Blacksburg, August 2002
