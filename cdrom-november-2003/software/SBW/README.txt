
	     S y s t e m s   B i o l o g y   W o r k b e n c h

	Andrew Finney, Michael Hucka, Herbert Sauro, Hamid Bolouri
	Ben Kovitz, Akira Funahashi, Sarah Keating, Joanne Matthews

	      The Systems Biology Workbench Development Group
		JST ERATO Kitano Symbiotic Systems Project
		 Control and Dynamical Systems, MC 107-81
		    California Institute of Technology
			 Pasadena, CA, 91125, USA

			 http://www.sbw-sbml.org/
		      mailto:sysbio-team@caltech.edu

----------------
1.  Introduction
----------------

Researchers make use of a large number of different software packages for
computational modeling and analysis as well as data manipulation and
visualization.  To help software developers easily provide the ability for
their applications to communicate with other tools, we have developed a
simple, open-source, application integration framework, the ERATO Systems
Biology Workbench (SBW).  Our aim has been to create a framework so simple
that software developers find it easier to build in an SBW interface than
to recreate functionality available in other tools.  By doing so, we hope
developers can concentrate on developing best-of-breed solutions in the
areas where they have special expertise.  

SBW uses a portable broker-based architecture that enables applications
(potentially running on separate machines) to learn about and communicate
with each other.  The communications facilities allow heterogeneous
packages to be connected together using a remote procedure call mechanism;
this mechanism uses a simple message-passing network protocol and allows
either synchronous or asynchronous invocations.  The interfaces to the
system are encapsulated in client libraries for different programming
languages (currently C, C++, Delphi, Java, Perl and Python), but the
protocol is open and small, and developers may implement their own
interfaces to the system if they choose.

Here is a summary of the features of SBW:

* Open source under the GNU LGPL license.

* Languages supported: C, C++, Delphi, Java, Perl, Python.

* Windows (98SE, 2000, XP), Linux and FreeBSD supported, with support for
  MacOS X and other versions of Windows expected in the future.

* Distributed operation via SSH, featuring remote starting of modules.

* CORBA gateway allowing bidirectional communications between SBW modules
  and programs using CORBA.

* Collection of basic modules provided with the SBW distribution:

  - A simple stochastic simulator based on the Gibson-Bruck variant of the
    Gillespie algorithm

  - An SBML-to-MATLAB ODE or Simulink file translator

  - An SBML reader tool that allows a program to extract (via an API) the
    components of an SBML description

  - A "clipboard" module that stores an SBML model description, for
    allowing the easy transfer of models between separate modules

  - An SBW Browser module that allows querying the SBW environment for
    registered modules and producing descriptions of each module's
    interfaces in various formats

  - A simple plotting module for time-series data

  - A generic simulation-control GUI interface.

  - A collection of tutorial example modules in C, C++, Delphi and Java

* Extensive documentation: in addition to overview documents and published
  papers, every language library has its own programmer's manual and API
  reference.

In addition, there are now many third-party modules available, including a
visual tool for defining biochemical reaction networks and a ODE-based
biochemical network simulator.  Please visit the project web site,
http://www.sbw-sbml.org/, for a complete list and pointers to these tools.

See the file NEWS.txt for information about changes and features in the
latest release.


--------------------------------
2.  Contents of the Distribution
--------------------------------

AUTHORS.txt 	  -- List of authors who have contributed to SBW
COPYING.txt	  -- Licensing terms
README.txt	  -- This file
NEWS.txt	  -- Release notes and change history
VERSION.txt	  -- Current release version number, for quick reference
docs		  -- Documentation
src		  -- Source code


----------------
3.  Installation
----------------

SBW releases come in two forms: self-extracting installers, and source
releases (in zip archive format).

The self-extracting installer is a complete, ready-to-go installation.  It
comes in a stripped-down version without source code or API documentation,
and a full version that includes source code and documentation.  With
either one, you should not actually need to compile anything; the
precompiled binaries should run out-of-the box.

If you obtained SBW in the form of a zip file (i.e., *not* as a
self-extracting installer), then you will need to build and install SBW.
Please see the file src/INSTALL.txt for more information on how to do this.


-----------------------------------
4.  Mailing lists and collaboration
-----------------------------------

Please go to http://sourceforge.net/projects/sbw and visit the mailing list
area for the Systems Biology Workbench project.  There you can add yourself
to different mailing lists related to the project.

Your feedback will help us to make a better and more portable package.
Consider documentation errors as bugs, and report them as such.  If you
develop anything pertaining to SBW or have suggestions, let us know and
share your findings by using the bug tracking facilities for the project at
http://sourceforge.net/projects/sbw/.


------------------------------------------
5.  Licensing, Copyrights and Distribution
------------------------------------------

The terms of redistribution for this software are stated in the file
COPYING.txt.  Please note also the copyright statements in the individual
source code files.


-------------------------------------------
File author: M. Hucka
Last Modified: $Date: 2003/08/12 20:48:46 $
-------------------------------------------
