(in-package :ecocyc)

#|
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
|#

;  This file contains  Lisp functions for querying Pathway Tools
;  databases and for generating an SBML file from the results.



(setq *all-orgs* '((VCHO "Vibrio-cholerae-N16961")
	       (TPAL "Treponema-pallidum-Nichols")
	       (PSEUDO "Pseudomonas-aeruginosa-PAO1")
	       (MTBRV "Mycobacterium-tuberculosis-H37Rv")
	       (MTBCDC "Mycobacterium-tuberculosis-CDC1551")
	       (MPNEU "Mycoplasma-pneumoniae")
	       (META "Metacyc")
	       (HPY "Heliobacter-pylori-26685")
	       (HINF "Haemophilus-influenza")
	       (ECOLI "Escherichia-coli-K-12")
	       (CTRA "Chlanydia-trachomatis-D-UW-3-CX")
	       (CAULO "Caulobacter-crescentus")
	       (BSUB "Bacillus-subtilis")
	       (AGRO "Agrobacterium-tumefaciens-C58")))

;    * AgroCyc -- Agrobacterium tumefaciens
;    * HpyCyc -- Helicobacter pylori
;    * MtbCdcCyc -- Mycobacterium tuberculosis CDC1551
;    * MtbRvCyc -- Mycobacterium tuberculosis H37Rv
;    * PseudoCyc -- Pseudomonas aeruginosa
;    * VchoCyc -- Vibrio cholerae 


(setq *open-orgs* '((VCHO "Vibrio-cholerae-N16961")
		    (AGRO "Agrobacterium-tumefaciens-C58")
		    (HPY "Heliobacter-pylori-26685")
		    (MTBRV "Mycobacterium-tuberculosis-H37Rv")
		    (MTBCDC "Mycobacterium-tuberculosis-CDC1551")
		    (PSEUDO "Pseudomonas-aeruginosa-PAO1")))

(defun generate-sbml (org-list dir-name)
  (sri::check-and-create-directory (format nil "~Amodels/" dir-name))
  (sri::check-and-create-directory (format nil "~Adoc/" dir-name))
  (loop for org in org-list
    for org-id = (car org)
    for org-name = (cadr org)
    do 
    (select-organism :org-id org-id)
    (2sbml (format nil "~A/models/~A.xml" dir-name org-name) 
	   (append (all-rxns :enzyme) (all-rxns :transport))
	   org-id org-name 'nil)
    (2html (format nil "~A/doc/~A.html" dir-name org-name) 
	   (append (all-rxns :enzyme) (all-rxns :transport)) 
	   org-id org-name 'nil)))



(defun smm-transport-rxns2sbml (filename &optional (org-id 'ecoli) (org-name "Biocyc"))
  (2sbml filename
	 (append (all-rxns :smm)
		 (all-rxns :transport))
	 org-id
	 org-name 'nil))

(defun balanced-p (rxn &optional (tolerance 0.0))
  (setq sum 0.0)
    (loop for reactant in (get-slot-values rxn 'left)
              do (let ((coefficient  (get-coefficient rxn 'left reactant))
		       (molecular-weight (get-molecular-weight reactant)))
		   (setq sum (- sum (* molecular-weight coefficient)))
		   ))
    (loop for product in (get-slot-values rxn 'right)
              do (let ((coefficient  (get-coefficient rxn 'right product))
		       (molecular-weight (get-molecular-weight product)))
		   (setq sum (+ sum (* molecular-weight coefficient)))
		   ))
    (>= tolerance (abs sum)))

(defun balanced-rxns2sbml (filename &optional (org-id 'ecoli) (org-name "Biocyc"))
  (2sbml filename
	 (append (all-rxns :smm)
		 (all-rxns :transport))
	 org-id
	 org-name
	 #'molecular-weight-p))

(defun balanced-rxns2html (filename &optional (org-id 'ecoli) (org-name "Biocyc"))
  (2html filename
	 (append (all-rxns :smm)
		 (all-rxns :transport))
	 org-id
	 org-name
	 #'molecular-weight-p))
		 
(defun make-html (org-id rxn-list &optional (org-name "Biocyc"))
  (format t "<html>~%<head><title>SBML model for ~A</title>~%" org-name)
  (format t "<link rel=\"stylesheet\" type=\"text/css\" href=\"models.css\">~%</head>~%")
  (print-notes org-id (append (all-rxns :smm) (all-rxns :transport)) org-name 'nil)
  (format t "</html>~%"))

;; Function: 2sbml
;; Returns:  NIL
;; Arguments: filename - output file
;;            rxn-list - a list of reaction frames
;;            org-id - the biocyc :org-id (default ecoli)
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
  
;  A. Generate a model of E. coli describing all enzyme-catalyzed
;     reactions and transport reactions:
  
;    EC(1): (2sbml "ecoli-all.xml" (append (all-rxns :enzyme) (all-rxns :transport))
;    'ecoli "Escherichia coli K-12")
  
;  B. Generate a model of Bacillus subtilis describing only
;     small-molecule reactions that are balanced: 
  
;    EC(2): (select-organism :org-id 'BSUB)
;    EC(3): (2sbml "bsub-balanced-small-molecules.xml"
;    (all-rxns :small-molecule)  "Bacillus subtilis" #'balanced-p)
  
;  C. Generate a web page describing all the small molecule metabolism
;     reactions of Vibrio cholerae N16961:
  
;    EC(4): (select-organism :org-id 'VCHO)
;    EC(5): (2html "vcho-smm.html" (all-rxns :smm) 'VCHO "Vibrio cholerae N16961")
  
;  D. Generate a web page describing only those Metacyc reactions which have
;     molecular weights for each reactant and products:
  
;    EC(5): (select-organism :org-id 'META)
;    EC(6): (2html "Metacyc-molecular-weights.html" (all-rxns) 'META
;          "MetaCyc" #'molecular-weight-p)
  


(defun 2sbml  (filename rxn-list &optional 
			(org-id 'ecoli)  (org-name "Biocyc") (filter-p 'nil))
   (cond ((fequal nil filter-p)
	  (tofile filename 
		  (make-sbml org-id rxn-list org-name)))
	 (t (tofile filename 
	    (make-sbml org-id 
		       (rxn-filter rxn-list filter-p)
		       org-name)))))

(defun 2html (filename rxn-list &optional 
		       (org-id 'ecoli)  (org-name "Biocyc")(filter-p 'nil))
  (cond ((fequal nil filter-p)
	 (tofile filename
		 (make-html org-id rxn-list org-name)))
	(t (tofile filename
		   (make-html org-id (rxn-filter rxn-list filter-p)
			      org-name)))))

;; Function: rxn-filter - screens a list of reactions for offending criteria
;; Returns: a list of reactions
;; Arguments: rxn-list - a list of reaction frames
;;            filter-p - a boolean function that takes a reaction frame as an argument
;; Examples: (rxn-filter (all-rxns) #'balanced-p)

(defun rxn-filter (rxn-list filter-p &optional args)
  (let ((filtered-list '()))
    (loop for rxn in rxn-list
      when (funcall filter-p rxn args)
      do (pushnew rxn filtered-list))
    filtered-list))

;; Function: molecular-weight-p - checks to see if all substrates of a reaction have a molecular weight. (It actually does not currently check to see if the reaction is balanced)
;; Returns:  boolean - t if the reaction is balanced, 'nil otherwise
;; Arguments: rxn - a reaction frame
;; Example:  (molecular-weight-p '|CITRATE-(RE)-SYNTHASE-RXN|) ==> t
;;           (molecular-weight-p 'THIOREDOXIN-REDUCT-NADPH-RXN) ==> NIL
;;
(defun molecular-weight-p (rxn &optional args)
  (setq balanced 't)
   (loop for substrate in (substrates-of-reaction rxn)
	 do (if (equal 0 (get-molecular-weight substrate))
	     (setq balanced 'nil)))
   balanced)

(defun get-molecular-weight (metabolite)
  (if  (and (coercible-to-frame-p metabolite) (not (fequal nil (get-slot-value metabolite 'molecular-weight))))
      (get-slot-value metabolite 'molecular-weight)
    0))


;; This function returns an SBML string to the standard output
;; Returns: NIL
;; Arguments: org-id - Biocyc id of the organism
;;            rxn-list - list of reaction frames
;; Example usage:  
;;         (make-sbml 'ecoli (all-rxns :smm))
;;
(defun make-sbml (org-id rxn-list &optional (org-name "Biocyc"))
  (select-organism :org-id org-id)
	 (print-header org-id org-name)
	 (print-notes org-id rxn-list org-name)
	 (print-list-of-compartments (list "cytoplasm" "extracellular" "dna"))
	 (print-list-of-species rxn-list)
	 (print-list-of-reactions rxn-list)
	 (print-footer))

(defun print-table (thead tbody bgcolor)
  (format t "      <table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"2\">~%      <thead><tr>~%")
  (loop for head in thead
    do (format t "        <th align=\"left\" valign=\"middle\" bgcolor=\"~A\">~A</th>~%" bgcolor head))
  (format t "      </tr></thead>~%      <tbody>~%")
  (loop for trow in tbody
    do (format t "        <tr>~A~%</tr>" trow))
  (format t "      </tbody>~%      </table>~%"))
  
(defun print-notes (org-id rxn-list &optional (org-name "Biocyc") (html-p t))
  (setq bgcolor "#cccccc")
  (format t " <notes>~%    <body xmlns=\"http://www.w3.org/1999/xhtml\">~%" )
  (format t "      <table border=\"0\" cellspacing=\"0\" cellpadding=\"2\">~%      <thead><tr>~%")
  (format t "        <th align=\"left\" valign=\"middle\" bgcolor=\"~A\">~A</th>~%" bgcolor (format nil "SBML model for ~A" org-name))
  (format t "        </tr></thead><tbody><tr><td>")
    (print-table (list "Citations")
		 (list (print-citation "D. Segre, J. Zucker, J. Katz, X. Lin, P. D'haeseleer, W. Rindone, P. Kharchenko, D. Nguyen, M. Wright, G. Church" 
		  "From annotated genomes to metabolic flux models and kinetic parameter fitting"
		  "http://genetics.med.harvard.edu/~dsegre/Segre_etal_OMICS_2003.pdf"
		  "OMICS 7:3 301-317 2003" )
	       (print-citation "P. Karp, S. Paley, and P. Romero"
		  "The Pathway Tools Software"
		  "http://www.ai.sri.com/pkarp/pubs/02ptools.pdf"
		  "Bioinformatics 18:S225-32 2002"))
	       bgcolor)
    (format t "</td></tr><tr><td>")
    (print-table (list "Description")
	       (list (print-summary org-id))
	       bgcolor)
    (format t "</td></tr><tr><td>")
    (print-table (list "Reaction" "Reaction Equation")
	       (print-reaction-table org-id rxn-list html-p)
	       bgcolor)
    (format t "</td></tr></tbody></table>")

    (print-note-footer "biocyc2sbml.lisp" "1.14" "October 21, 2003" "zucker@research.dfci.harvard.edu" "Jeremy Zucker"))
  
(defun print-note-footer (prog-name version date email author)
  (format t "<hr/><p>Generated by ~A version ~A on ~A</p><p><address><a href=\"mailto:~A\">~A</a></address></p>~%    </body>~%  </notes>~%" prog-name version date email author))

(defun print-citation (authors title link journal)
  (format nil "<td>~A<br/>~%        <a href=\"~A\">&quot;~A,&quot;</a><br/>~%        ~A</td>~%" 
	  authors link title journal))

(defun print-summary (org-id)
  (format nil "<td>The ~A model was generated from the <a href=\"http://biocyc.org:1555/~A/new-image?type=OVERVIEW\">Organism-specific Pathway/Genome database</a></td>" org-id org-id))


(defun print-reaction-table (org-id rxn-list html-p)
  (setq toggle -1)
  (setq *rows* '())
  (loop for rxn in rxn-list
    do (if (> toggle 0)
	   (pushnew (print-row org-id 'reaction rxn "#eeeeee" html-p) *rows*)
	(pushnew (print-row org-id 'reaction rxn "#ffffff" html-p) *rows*))
    (setq toggle (* toggle -1)))
  *rows*)

(defun print-row (org-id type object bgcolor &optional (html-encode-p t))
  (format nil "      <td align=\"left\" valign=\"middle\" bgcolor=\"~A\">~A</td><td align=\"left\" valign=\"middle\" bgcolor=\"~A\">~A</td>~%"
	  bgcolor
	  (print-description object html-encode-p)
	  bgcolor
	  (print-link org-id type object html-encode-p)))
  
(defun print-link (org type object &optional (html-encode-p t))
  (cond ((fequal t html-encode-p)
	 (setq *rxn* (html-encode (get-name-string object :rxn-eqn-as-name? t :strip-html? 'nil)))
	 (setq *object* (html-encode object)))
	(t
	 (setq *rxn* (get-name-string object :rxn-eqn-as-name? t :strip-html? 'nil))
	 (setq *object object)))
  (format 'nil "<a href=\"http://BioCyc.org:1555/~A/new-image?type=~A&amp;object=~A\">~A</a>"
	  org type *object* *rxn*))
	  

(defun print-description (object &optional (html-encode-p t))
  (if (fequal t html-encode-p)
      (html-encode (get-name-string object :rxn-eqn-as-name? 'nil :strip-html? 'nil))
    (get-name-string object :rxn-eqn-as-name? 'nil :strip-html? 'nil)))
 

(defun print-header (org-id org-name)
    (let ((foobar "http://www.sbml.org/sbml/level2"))
      (format t "<?xml version=\"1.0\"?>~%<sbml xmlns=\"~A\" version=\"1\" level=\"2\">~%" foobar)
      (format t "<model id=\"~A\" name=\"Generated from ~A Pathway/Genome Database 7.5\">~%" org-id org-name)))

(defun print-list-of-compartments (compartment-list)
  (format t "<listOfCompartments>~%")
  (loop for compartment in compartment-list
    do (format t "  <compartment id=\"~A\"/>~%" compartment))
  (format t "</listOfCompartments>~%"))


(defun print-list-of-species (rxn-list)
  (format t "<listOfSpecies>~%")
  (print-substrate-species rxn-list)
  (print-transported-species rxn-list)
  (print-enzyme-species rxn-list)
  (print-gene-species rxn-list)
  (format t "</listOfSpecies>~%"))


(defun print-list-of-reactions (rxn-list)
  (format t "<listOfReactions>~%")
  (print-gene-enzyme-reaction rxn-list)
  (loop for rxn in rxn-list
    for id = (get-sid rxn)
    for name = (get-cycid rxn)
    for reversible = (reversible-p rxn)
    when (substrates-of-reaction rxn)
    do  (print-reaction id name reversible))
  (format t "</listOfReactions>~%"))

      
(defun print-substrate-species (rxn-list)
  (loop for substrate in (extract-list rxn-list #'substrates-of-reaction)
    do (print-species (get-sid substrate) 
		      (get-cycid substrate) 
		      "cytoplasm"
		      'nil)))

(defun get-transported-chemicals (rxn)
  (let ((*transported-chemicals* '()))
    (loop for reactant in (get-slot-values rxn 'left)
	  when (fequal 'periplasm (get-value-annot rxn 'left reactant 'compartment))
	  do (pushnew reactant *transported-chemicals*))
    (loop for product in (get-slot-values rxn 'right)
	  when (fequal 'periplasm (get-value-annot rxn 'right product 'compartment))
	  do (pushnew product *transported-chemicals*))
    *transported-chemicals*))

(defun print-transported-species (rxn-list)
  (loop for transported-species in (extract-list rxn-list #'get-transported-chemicals)
    do (print-species (get-transport-sid transported-species "extracellular") 
		      (get-cycid transported-species) 
		      "extracellular"
		      'nil)))
  
(defun print-enzyme-species (rxn-list)
  (loop for enzyme in  (extract-list rxn-list #'enzymes-of-reaction)
;;    when (coercible-to-frame-p enzyme)
    do (print-species (get-sid enzyme) 
		      (get-cycid enzyme) 
		      "cytoplasm"
		      'nil)))

(defun print-gene-species (rxn-list)
  (loop for gene in (extract-list (extract-list rxn-list #'enzymes-of-reaction) #'genes-of-protein)
    do (print-species (get-sid gene)
		      (get-cycid gene)
		      "dna"
		      'nil)))
(defun print-footer ()
  (format t "</model>~%</sbml>~%"))

;; Function: extract-list - finds unique derived elements of a list
;; Returns: A unique list of elements derived from the extraction function applied to the input list
;; Arguments: the-list - a list of frames
;;            extraction-function - a function which returns a list and takes an element of the-list as an argument
;; Examples: (extract-list (all-rxns :transport) #'transported-chemicals)
;;           (extract-list (all-rxns :smm) #'substrates-of-reaction)
;;           (extract-list (all-rxns :enzyme) #'enzymes-of-reaction)

(defun extract-list (the-list extraction-function)
  (setf *hash* (make-hash-table))
  (loop for element in the-list
    when (coercible-to-frame-p element)
    do (loop for key in (funcall extraction-function element)
	do (if (not (gethash key *hash*))
	       (setf (gethash key *hash*) 1)
	     )))
  (let ((extraction-list '()))
    (loop for key being the hash-keys of *hash*
      do (pushnew key extraction-list))
    extraction-list))

(defun get-name (name)
    (html-encode (get-name-string name :rxn-eqn-as-name? 'nil :strip-html? 'nil)))

(defun print-species (id name compartment annotation)
  (format t "  <species id=\"~A\" name=\"~A\" initialAmount=\"0\" compartment=\"~A\" boundaryCondition=\"false\"" id (get-name name) compartment)
  (cond ((fequal 'nil annotation)
	 (format t "/>~%"))
	(t (format t ">~%")
	   (funcall annotation (get-cycid name))
	   (format t "  </species>~%"))))

(defun print-enzyme-annotation (enzyme)
  (cond ((not (fequal nil (genes-of-protein enzyme)))
	 (format t "      <annotation xmlns:fbml=\"http://arep.med.harvard.edu/fbml\">~%")
	 (loop for gene in (genes-of-protein enzyme)
	   do (format t "         <fbml:gene id=\"~A\" name=\"~A\"/>~%"
		      (get-sid gene)
		      ;;(get-cycid gene)
		      (get-name gene)))
	 (format t "      </annotation>~%"))))

(defun print-gene-enzyme-reaction (rxn-list)
  (loop for enzyme in (extract-list rxn-list #'enzymes-of-reaction)
    when (genes-of-protein enzyme)
    do (format t "<reaction id=\"~A\" name=\"~A\" reversible=\"false\">~%"
	    (concatenate 'string (get-sid enzyme) "_protein_complex")
	    (get-name enzyme))
    (format t "  <listOfReactants>~%")
    (loop for gene in (genes-of-protein enzyme)
      do (print-species-reference
	  (get-sid gene)
	  "1")
      )
    (format t "  </listOfReactants>~%")
    (format t "  <listOfProducts>~%")
    (print-species-reference (get-sid enzyme) "1")
    (format t "  </listOfProducts>~%")
    (format t "</reaction>~%")))
      

(defun print-reaction (sid name reversible)
  (let ((rxn (get-cycid name)))
    (format t 
	    "<reaction id=\"~A\" name=\"~A\" reversible=\"~A\">~%"
	    sid
	    (get-name name)
	    reversible)
    (print-list-of-reactants  rxn)
    (print-list-of-products rxn)
    (print-list-of-modifiers  rxn)
    (format t "</reaction>~%")))

(defun print-list-of-reactants (rxn)
  (format t "   <listOfReactants>~%")
  (loop for reactant in (get-slot-values rxn 'left)
    
    do (print-species-reference 
	(get-transport-species rxn 'left reactant)
	(get-coefficient rxn 'left reactant)))
  (format t "   </listOfReactants>~%"))

(defun print-list-of-modifiers (rxn)
  (cond ((not (fequal 'nil (enzymes-of-reaction rxn)))
	 (format t "   <listOfModifiers>~%")
	 (loop for enzyme in (enzymes-of-reaction rxn)
	   do (print-modifier-species-reference (get-sid enzyme)))
	 (format t "   </listOfModifiers>~%"))))

(defun print-modifier-species-reference (species)
  (format t "      <modifierSpeciesReference species=\"~A\"/>~%" species))

(defun get-transport-species (rxn side species)
  (if (fequal 'PERIPLASM (get-compartment rxn side species))
      (get-transport-sid species "extracellular")
    (get-sid species)))

(defun print-list-of-products (rxn)
  (format t "   <listOfProducts>~%")
  (loop for product in (get-slot-values rxn 'right)
    do (print-species-reference
	(get-transport-species rxn 'right product)
	(get-coefficient rxn 'right product)))
  (format t "   </listOfProducts>~%"))

(defun print-species-reference (species stoichiometry)
  (format t "      <speciesReference species=\"~A\" stoichiometry=\"~A\"/>~%"
	  (strip-html species)
	  stoichiometry))




(defun get-transport-sid (transporter compartment)
  (concatenate 'string  (get-sid transporter) "_" compartment ))

  
  
;; param fname - a db object
;;  returns the frame name if fname is coercible to a frame,
;; otherwise returns fname
(defun get-sid (fname)
    (if (coercible-to-frame-p fname)
       (cyc2sid (get-frame-name fname))
       (cyc2sid fname)))

(defun get-cycid (sid)
  (let ((cycid (intern (sid2cyc sid))))
    (cond 
     ((coercible-to-frame-p sid)
      (get-frame-name sid))
     ((coercible-to-frame-p cycid)
      (get-frame-name cycid))
     (t cycid))))

;(defun cyc2sid (cyc)
;  (excl:replace-regexp
;   (replace-regexp (2string cyc)
;		   "[^0-9A-Za-z_]"
;		   "_")
;   "^\\([0-9]\\)"
;   "_\\1"))
   

(defun cyc2sid (cyc)
  (excl:replace-regexp 
   (replace-regexp (2string cyc)
		   (excl:compile-regexp "\\([^0-9A-Za-z_]\\)")
		   "__~d__" 
		   #'(lambda (x) 
		       (char-code (coerce x 'character))))
   (excl:compile-regexp "^\\([0-9]\\)")
   "_\\1"))
	

(defun sid2cyc (sid)
  (let ((compartment "extracellular")
	(sid (2string sid)))
    (excl:replace-regexp
     (replace-regexp 
      (if (not (compartment-p sid compartment))
	  sid
	(subseq sid 0 (- (length sid)
			 (length compartment))))
      "__\\([0-9]+\\)__"
      "~A"
      #'(lambda (x) (string (code-char (parse-integer x :junk-allowed t)))))
     "^_\\([0-9]+\\)"
     "\\1")))


;(defun sid2cyc (SId)
;  (let ((compartment "extracellular")
;	(SId (2string SId)))
;    (intern 
;     (substitute 
;      #\- #\_ 
;      (if (compartment-p SId  compartment)
;	  (subseq SId 0 (- (length SId) 
;			   (length compartment)
;			   1))
;	SId)))))

(defun 2string (fname)
  (cond ((coercible-to-frame-p fname)
	 (symbol-name (get-frame-name fname)))
	((symbolp fname)
	 (symbol-name fname))
	((stringp fname)
	 fname)))
  
;; get-compartment takes a reaction frame and a compound frame and returns the compartment which the metabolite is in
(defun get-compartment (rxn side metabolite)
    (setq compartment (get-value-annot rxn side metabolite 'compartment))
        (cond  ((fequal nil compartment)
                (setq compartment "cytoplasm")))
        compartment)

;; get-coefficient takes a reaction frame and a compound frame and returns the coefficient of the metabolite in the reaction    
(defun get-coefficient (rxn side metabolite)
    (setq coefficient (get-value-annot rxn side metabolite 'coefficient))
    (cond ((fequal nil coefficient)
           (setq coefficient 1))
	  ((fequal 'N coefficient)
	   (setq coefficient 1))
	  ((fequal 'M coefficient)
	   (setq coefficient 1))
	  ((fequal '2N coefficient)
	   (setq coefficient 2))
	  ((excl:match-regexp "\\([0-9\\.]+\\)d\\([0-9]+\\)" 
			      (format nil "~d" coefficient))
	   (setq coefficient (intern (excl:replace-regexp 
				      (format nil "~d" coefficient)
				      "\\([0-9\\.]+\\)d\\([0-9]+\\)"
				      "\\1")))))
	  coefficient)
    


(defun transported-p (rxn side compound)
  (get-value-annot rxn side compound 'compartment))
     
	  

(defun compartment-p (SId compartment)
  (eq (- (length SId) (length compartment)) 
      (mismatch SId compartment :from-end t)))

(defun reversible-p (rxn)
  (cond ((get-slot-value rxn 'spontaneous?) "true")
	((fequal nil (get-slot-value rxn 'enzymatic-reaction)) "true")
	((fequal 'reversible 
		 (get-slot-value (get-slot-value rxn 'enzymatic-reaction)
				 'reaction-direction)) "true")
	(t "false")))
	
(defun strip-html (string)
  (excl:replace-regexp (2string string) (excl:compile-regexp "<.*>") "_" :shortest t))

(defun html-encode (string)
  (excl:replace-regexp
   (excl:replace-regexp 
    (excl:replace-regexp
     (excl:replace-regexp
      (excl:replace-regexp (2string string) "&" "&amp;" )
      "<" "&lt;")
     ">" "&gt;")
    "\"" "&quot;")
   "'"  "&apos;"))


;; Function: replace-regexp - overloads excl:replace-regexp
;; Returns: A string
;; Arguments: string - the string to be replaced
;;            regexp - A regular expression
;;            replacement - a formatted string
;;            replacement-function - a function of the matched string
;; Example:  (replace-regexp "foo(x)" "[^a-z_]" "_") ==> foo_x_
;;           (replace-regexp "foo(x)" "[^a-z_]" "__~d__" 
;;                           #'(lambda (x) (code-char (coerce x 'character))))
;;           ==> foo__40__x__41__
;; Note: the replacement-function argument can cause a lot of naughtiness
;; if you are not careful with your regexp and replacement.  

;; For example not including an underscore in the regexp argument of the last example is a BAD IDEA 
;; 

(defun replace-regexp (string regexp replacement &optional replacement-function)
  (if (fequal nil replacement-function)
      (excl:replace-regexp string regexp replacement)
    (multiple-value-bind (match-p whole-match match) 
	(excl:match-regexp regexp string :return :string) 
      (if (fequal nil match-p)
	  string
	(replace-regexp
	 (excl:replace-regexp string (escape-regexp whole-match)
		(format nil replacement 
			(funcall replacement-function match)))
	 regexp replacement replacement-function)))))


;; Function: escape-regexp - removes the special meanings from characters
;; Returns: A regular expression object
;; Arguments: string - the regular expression
;; Example: (escape-regexp "[") ==> "\\["

(defun escape-regexp (string) 
  (excl:compile-regexp (excl:replace-regexp string 
		       "\\(\\[\\|\\.\\|\\]\\|\\+\\|\\^\\|\\$\\)" 
		       (concatenate 'string "\\" string))))

  
(defun html-decode (string)
  (excl:replace-regexp
   (excl:replace-regexp 
    (excl:replace-regexp (2string string) "&gt;" ">" )
    "&lt;" "<")
   "&amp;" "&"))



;; This macro was taken verbatim from the example Pathway Tools queries at
;; http://bioinformatics.ai.sri.com/ptools/examples.lisp
;; This macro sends all output generated by Body that would normally go
;; to the terminal to the file named by Filename.
;;
;;   Example usage:
;;      (tofile "~/genes.dat" (gene-table (find-gene-by-substring "trp")))

(defmacro tofile (filename &body body)
  `(with-open-file (file ,filename
		    :direction :output
		    :if-exists :supersede)
     (let ((*standard-output* file))
       ,@body) )
  )


