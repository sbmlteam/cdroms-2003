###################################################################################

Biocyc2SBML description:
========================

  A tool for converting the information contained in the Biocyc
  Pathway/Genome Database into SBML models.
  
  Author: Jeremy Zucker <zucker@research.dfci.harvard.edu>

  History:  Version 1.16.  The original version of this program was
  written during the 2003 SBML Hackathon that was hosted at the
  Virginia Bioinformatics Institute. This is my first non-trivial
  Common Lisp program, so feedback is definitely encouraged. 


Requirements:
=============

  Biocyc2SBML depends on the Biocyc pathway tools suite distributed by SRI.  
  http://BioCyc.org/downloads.shtml
  To obtain the Software-Database Bundle, please contact
  biocyc-info@ai.sri.com to obtain a software license agreement. 
    o Universities, non-profit research institutes, government
      laboratories: Local installations of BioCyc are free for
      research purposes. 
    o Commercial sites: BioCyc is available for a fee to commercial
      institutions.  

  Operating System: Solaris 8, Linux (2.2 or higher kernel, OpenMotif,
  and glibc 2.1+), or Microsoft Windows 98/2000/NT/XP (not tested on
  Solaris 9 or Windows Me). 


    

Open Biocyc Databases:
======================

  The following version 7.5 Pathway/Genome databases are currently open:


    * AgroCyc -- Agrobacterium tumefaciens
    * HpyCyc -- Helicobacter pylori
    * MtbCdcCyc -- Mycobacterium tuberculosis CDC1551
    * MtbRvCyc -- Mycobacterium tuberculosis H37Rv
    * PseudoCyc -- Pseudomonas aeruginosa
    * VchoCyc -- Vibrio cholerae 

  SBML models generated from these databases can be redistributed and
  published without restriction. Please see
  http://biocyc.org/open-reg.shtml for details.


Non-open Biocyc Databases:
==========================

    * BsubCyc -- Bacillus subtilis
    * CauloCyc -- Caulobacter crescentus
    * CtraCyc -- Chlamydia trachomatis
    * EcoCyc -- Escherichia coli
    * HinCyc -- Haemophilus influenzae
    * MetaCyc -- Metabolic pathways and enzymes from 150 species
    * MpneuCyc -- Mycoplasma pneumoniae
    * PseudoCyc -- Pseudomonas aeruginosa
    * YeastCyc -- Saccharomyces cerevisiae
    * TpalCyc -- Treponema pallidum

SBML MODELS GENERATED FROM THESE DATABASES HAVE RESTRICTIONS ON
PUBLICATION AND REDISTRIBUTION. Please see
http://biocyc.org/all-reg.shtml for details. 



Invocation:
===========

  bash $  pathway-tools -lisp
  EC(1): (load "biocyc2sbml.lisp")
  ;   Loading /home/zucker/src/BPHYS/biocyc2sbml.lisp
  T
  EC(2): (generate-sbml *open-orgs* "biocyc-open/")
  ;; ensure-directories-exist: creating
  ;;   /home/zucker/src/BPHYS/biocyc-open/models
  ;; ensure-directories-exist: creating
  ;;   /home/zucker/src/BPHYS/biocyc-open/doc
  NIL
  EC(3): (generate-sbml *all-orgs*  "biocyc-full/")
  ;; ensure-directories-exist: creating
  ;;   /home/zucker/src/BPHYS/biocyc-full/models
  ;; ensure-directories-exist: creating
  ;;   /home/zucker/src/BPHYS/biocyc-full/doc
  NIL
  EC(4): :exit
        
  SBML models were generated with the following command:
   
  
  ;; Function: 2sbml
  ;; Returns:  NIL
  ;; Arguments: filename - output file
  ;;            rxn-list - a list of reaction frames
  ;;            org-id - the biocyc :org-id (default 'ecoli)
  ;;            org-name - a string which represents the full name of
  ;;            the organism
  ;;            filter-p - a boolean function that takes a single reaction 
  ;;                       frame and optionally one other argument as
  ;;                       parameters.  (default 'nil)
  ;; Example usage:
  
  A. Generate a model of E. coli describing all enzyme-catalyzed
     reactions and transport reactions:
  
    EC(1): (2sbml "ecoli-all.xml" (append (all-rxns :enzyme) (all-rxns :transport))
    'ecoli "Escherichia coli K-12")
  
  B. Generate a model of Bacillus subtilis describing only
     small-molecule reactions that are balanced: 
  
    EC(2): (select-organism :org-id 'BSUB)
    EC(3): (2sbml "bsub-balanced-small-molecules.xml"
    (all-rxns :small-molecule)  "Bacillus subtilis" #'balanced-p)
  
  C. Generate a web page describing all the small molecule metabolism
     reactions of Vibrio cholerae N16961:
  
    EC(4): (select-organism :org-id 'VCHO)
    EC(5): (2html "vcho-smm.html" (all-rxns :smm) 'VCHO "Vibrio cholerae N16961")
  
  D. Generate a web page describing only those Metacyc reactions which have
     molecular weights for each reactant and products:
  
    EC(5): (select-organism :org-id 'META)
    EC(6): (2html "Metacyc-molecular-weights.html" (all-rxns) 'META
          "MetaCyc" #'molecular-weight-p)
  

SBML Validation
===============

  Each SBML model generated can be validated using the testSBML script
  in the test directory.  The testSBML script assumes that
  libsbml-2.0.1 has been installed in /usr/local.  Please change
  LD_LIBRARY_PATH if this is not the case. 

  Additionally, all generated SBML models can be validated with the
  software packages listed on http://www.sbml.org

Bugs, Kludges, and Hacks:
=========================

  There were a few tweaks which needed to happen in order to successfully validate:

  1. SBML unique identifiers may only contain numbers, letters or underscores.  Furthermore,
  the first character cannot be a number.  According to the BNF grammar
  
  on  page 7 of the level 2 SBML spec:
  
  letter ::= 'a'..'z', 'A'..'Z'
  digit ::= '0'..'9'
  nameChar ::= letter | digit | '_'
  name ::=  ( letter | '_' ) nameChar*
  |
  
  
  This is in contrast to Biocyc unique identifiers which
  may contain parentheses, dashes, or html markup. 
   
  In order to ensure that no information is lost when converting a
  Biocyc id to an SID, the following algorithm is employed: 
  
    a. If the first character is not a letter, prepend a single
       underscore. i.e. 2-OCTAPRENYLPHENOL becomes _2-OCTAPRENYLPHENOL
  
    b. For each character in the Biocyc id, if the character is not alphanumeric or underscore,
       replace the character with its ascii value delimited by a double
       underscore.  i.e. _2-OCTAPRENYLPHENOL becomes _2__45__OCTAPRENYLPHENOL
  
  
  Note that this algorithm is reversible as long as Biocyc never uses an
  underscore at the beginning of an id and never happens to have an id
  with a number delimited by double underscores.  Fortunately, it does
  not. 
  
  2. In the notes section, XHTML does not appear to recognize entities
  such as &beta; and &gamma;  To handle this namespace issue, all
  names and reaction equations and are html-encoded such that  EC#
  5.1.3.3, the ALDOSE-1-EPIMERASE-RXN has a reaction equation of:
  
  &amp;alpha;-D-glucose   =   &amp;beta;-D-glucose
  
  
  3. According to the current SBML specification, a compound that is
  transported must have an  
  identifier for each compartment. I solve this problem
  by creating 2 species tags for each transported chemical, and use the correct 
  speciesReference in the transport reaction.
   
  4. Coefficients of a reaction had to be normalized in order to be
  accepted by the SBML spec.    
  Fortunately, the newest level 2 specification accepts floating point
  numbers for stoichiometry: 
  
  Biocyc coefficient  ==> SBML stoichiometry
  N    ==> 1
  2N ==> 2
  M ==> 1
  0.5d0 ==> 0.5
  
  5. To represent the relationship of genes to enzymes to reactions, the
  following convention is used:
    a.  Genes are a species that is only found in the DNA compartment
    b.  Enzymes are a species that are only found in the cytoplasm
    c.  For each enzyme complex, a reaction exists where the reactants
        are the genes and the product is the enzyme complex.
    d.  For each enzyme-catalyzed reaction, a list of modifiers
        associates each enzyme with the reaction it catalyzes.
  

Acknowledgements: 
=================

  Thanks to Matthew Temple for giving me permission to
  pursue my interests. Thanks to Peter Karp and the Pathway-tools
  support team for making Biocyc a reality and providing the pathway-tools API.
  Thanks to the organizers  and participants of the SBML Hackathon
  for answering numerous arcane questions about SBML and providing
  food, lodging, and facilities for hacking.  Thanks to everyone in
  the Church lab, especially Daniel Segre, Wayne Rindone, and Xiaoxia
  Lin for  their support, my BPHYS 101 project partners Jeremy Katz
  and Julian Bonilla for embarking with me on this madness, and last 
  but not least George Church for getting 
  me excited about this project idea in the first place, and sending
  me to the Hackathon in the end.



##############################################################################
