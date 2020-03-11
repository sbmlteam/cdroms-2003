#!/usr/local/bin/perl
# 
# writesbml: Uses ecolifluxlist.txt file created by writenative to create an sbml 2 
# representation of the same information.
#
# Copyright (c) 2003 by Wayne Rindone and the President and Fellows of Harvard University

AnalyzeParameters(@ARGV);

# set up the reference list of defined abbreviations

processabbreviationfile(\%abblist,"revisedabbreviations.txt");

open (IN,$infile);
open (OUT,">$outfile");
open (EXC,">$excfile");

writefilestart(OUT); 

$incount = 0;
$fluxcount = 0;
$filepart = 1;
@fluxlist = ();

# Write the initial annotations as we read through the file

$firstline = <IN>;  # skip header line

print "first line is '$firstline'\n";

while ($line = <IN>) {
   chomp($line);
   @cols = split "\t",$line;
   $numcols = @cols;
   $fluxcount++;
   print $line."\n";
   print " has $numcols fields\n";

   $thisfluxname = $cols[0];
   $fluxlist[$fluxcount-1] = $thisfluxname;
   $thisgenelist = $cols[1];
   if ($thisgenelist eq "") {
      @thesegenesymbols = ();
   }
   else {
      @thesegenesymbols = split ",",$thisgenelist;
   }
   $thisdescription = $cols[2];
   $thisecnumber = $cols[3];
   $thisreactiontext = $cols[4];
   $thislowerlimit = $cols[5];
   $thisupperlimit = $cols[6];


   $thisdescription = replacecharacter($thisdescription,">","&gt;");
   $thisdescription = replacecharacter($thisdescription,"<","&lt;");
   $thisdescription = replacecharacter($thisdescription,"&","&amp;");
   print "transformed flux description is ".$thisdescription."\n";

   $firstnoteline = "           <p>".$thisdescription.", ";
   if ($thisgenelist ne "") {
      $firstnoteline = $firstnoteline.$thisgenelist.", ";
   }
   $firstnoteline = $firstnoteline."flux ".$thisfluxname." </p>";

   print OUT $firstnoteline."\n";

   for ($i=0; $i<@thesegenesymbols; ++$i) {
       while (substr($thesegenesymbols[$i],0,1) eq " ") {
	   $thesegenesymbols[$i] = substr($thesegenesymbols[$i],1);
       }
   }


   $thisreactiontext = processreaction($thisreactiontext,\%abblist,\%compoundlist,\%genelist,\%fluxreactants,\%fluxproducts,\%fluxmodifiers,\%fluxreverse,\@thesegenesymbols);

   addcompoundspecies(\@reactantnamearray,\%abblist,\%compoundlist);
   addcompoundspecies(\@productnamearray,\%abblist,\%compoundlist);
   addmodifierspecies(\@thesegenesymbols,$thisdescription,\%modifierlist);


   $secondnoteline = "           <p>".$thisfluxname.": ";
   $secondnoteline = $secondnoteline.$thisreactiontext."</p>";

   print OUT $secondnoteline."\n";

   if ($thislowerlimit eq "Inf") {
       $thislowerlimit = "INF";
   }
   elsif ($thislowerlimit eq "-Inf") {
       $thislowerlimit = "-INF";
   }

   if ($thisupperlimit eq "Inf") {
       $thisupperlimit = "INF";
   }
   elsif ($thisupperlimit eq "-Inf") {
       $thisupperlimit = "-INF";
   }

   $fluxlimits{$thisfluxname} = '             <annotation xmlns:flux="http://arep.med.harvard.edu/fluxns">
                     <flux:limitation lower="'.$thislowerlimit.'"/>
                     <flux:limitation upper="'.$thisupperlimit.'"/>
             </annotation>
';
   $fluxupper{$thisfluxname} = $thisupperlimit;

   $fluxdescription{$thisfluxname} = $thisdescription;

   $incount++;
}

close (IN);

# finish off the annotations and produce the compartment list and first line of Species list

#print OUT '            <p> WARNING - Although the flux balance model neither takes into </p>
#            <p> account nor models the amounts of any Species (it deals with fluxes) </p>
#            <p> it is required to supply an initialAmount value for each Species. </p>
#            <p> Therefore, we have arbitrarily set the initialAmount for every compound </p>
#            <p> and gene product to 0, which has no basis in reality.  These fake initialAmount </p>
#            <p> values should not be used with any other modeling approach. </p> 
print OUT '         </body>
      </notes>
      <listOfCompartments>
         <compartment id="cytoplasm"/>
         <compartment id="extracellular"/>
      </listOfCompartments>
      <listOfSpecies>
';

while (($compoundkeyname, $compoundvalue) = each %compoundlist) {
   print $compoundkeyname." is ".$compoundvalue."\n";
   $compoundvalue = replacecharacter($compoundvalue,">","&gt;");
   $compoundvalue = replacecharacter($compoundvalue,"<","&lt;");
   $compoundvalue = replacecharacter($compoundvalue,"&","&amp;");
   print "transformed ".$compoundkeyname." is ".$compoundvalue." and substr with offset -2 is '".substr($compoundkeyname,-2)."\n";
   if (substr($compoundkeyname,-2) eq "xt" || substr($compoundkeyname,-2) eq "XT") {
       $compartment = "extracellular";
   }
   else {
       $compartment = "cytoplasm";
   }

   print OUT '	 <species id="'.$compoundkeyname.'" name="'.$compoundvalue.'" 
		  compartment="'.$compartment.'" boundaryCondition="false"/>
';
}
while (($modifierkeyname, $modifiervalue) = each %modifierlist) {
   print $modifierkeyname." is ".$modifiervalue."\n";

   print OUT '	 <species id="'.$modifierkeyname.'" name="'.$modifiervalue.'"
		  compartment="cytoplasm" boundaryCondition="false"/>
';
}
# finish Species list and start Reaction list

print OUT '      </listOfSpecies>
      <listOfReactions>
';

for ($i=0; $i<@fluxlist; ++$i) {
    print OUT '         <reaction id="'.$fluxlist[$i].'" name="'.$fluxdescription{$fluxlist[$i]}.
'" reversible="'.$fluxreverse{$fluxlist[$i]}.'">
'.$fluxlimits{$fluxlist[$i]}.$fluxreactants{$fluxlist[$i]}.$fluxproducts{$fluxlist[$i]}.
$fluxmodifiers{$fluxlist[$i]}.'         </reaction>
';
}

print OUT '      </listOfReactions>
   </model>
</sbml>
';


$totalinputlines = $incount;

close (OUT);
close (EXC);

print "TPIA flux found in our file, line ".arrayloc(\@flux88,"TPIA")."\n";

print "Statistics generated by writenative\n\n";
print "  Number flux names listed in objvector.par: $totalfluxnumber\n";
print "  Number flux names explained in our file: $totalfrom88file\n";
print "  Number flux names listed in Palsson file: $totalfrompalssonfile\n";
print "  Number of problem reports: $exccount\n";
print "  A total of $incount lines were processed, listing a total of $fluxcount different fluxes\n";
print "Processing complete.\n";


sub AnalyzeParameters {
  my $i;

  if (@_==0) {
    Usage();
    exit;
  }

  for ($i=0; $i<@_; ++$i) {
    if ($_[$i] eq "-i") {
      $infile = $_[$i+1];
      ++$i;
    }
    if ($_[$i] eq "-o") {
      $outfile = $_[$i+1];
      ++$i;
    }
    if ($_[$i] eq "-e") {
      $excfile = $_[$i+1];
      ++$i;
    }
  }

  if ($infile eq "") {
      print "\nERROR: no input load file specified.  Use -i argument.\n";
      exit;
  }

  if ($outfile eq "") {
    print STDERR "Output file name defaulting to ".$infile."sbml2.xml.\n";
    $outfile = $infile."sbml2.xml";
  }

  if ($excfile eq "") {
    print STDERR "Exception list file name defaulting to $infile.exception.\n";
    $excfile = $infile.".exception";
  }
}

sub Usage {
  print <<_USAGE
    writesbml: Creates the sbml 2 representation of the native flux balance model
               file that is provided

Syntax: 
  writesbml -i native-load-file -o smbl-2-file -e list-of-exceptions

  if -o not provided, smbl-2-file name defaults to input
  native-load-file name followed by "sbml2.xml"

  if -e not provided, list-of-exceptions name defaults to 
  input native-load-file name followed by ".exceptions"

_USAGE
;
} 

sub processreaction {

   my $reactiontext = $_[0];
   my $abblist_ref = $_[1];
   my $compoundlist_ref = $_[2];
   my $genelist_ref = $_[3];
   my $fluxreactants_ref = $_[4];
   my $fluxproducts_ref = $_[5];
   my $fluxmodifiers_ref = $_[6];
   my $fluxreverse_ref = $_[7];
   local *genenames = $_[8];

#   local *reactioncols = $_[0];
#   my $thesenumcols = $_[1];
#   my $inreversible = $_[2];

   $newreactiontext = "";
   $numreactants = 0;
   $numproducts = 0;

#   for ($colcount = 0; $colcount<$thesenumcols-2; ++$colcount) {
#      $thiscount = substr($reactioncols[$colcount],0,7);
#      if ($thiscount < 0) {
#         $numreactants++;
#         $thiscount = - $thiscount;
#         if ($numreactants > 1) {
#            $newreactiontext = $newreactiontext." + ";
#         }
#      }
#      else {
#         $numproducts++;
#         $thiscount = - $thiscount;
#         $thiscount = - $thiscount;
#         if ($numproducts == 1) {
#            if ($inreversible == 1) {
#               $newreactiontext = $newreactiontext." <--> ";
#            }
#            else {
#               $newreactiontext = $newreactiontext." --> ";
#            }
#         }
#         else {
#            $newreactiontext = $newreactiontext." + ";
#         }
#      }
#      if ($thiscount != 1) {
#            $newreactiontext = $newreactiontext.$thiscount." ";
#      }
#      $colcount++;
#      $thiscompound = $reactioncols[$colcount];
#      if ($thiscompound eq "HEXT") {
#         $thiscompound = "H[out]";
#      }
#      if (index($thiscompound,"xt") > - 1) {
#         print "thiscompound started as '$thiscompound'";
#         $thiscompound = substr($thiscompound,0,-2)."[out]";
#         print " and it was changed to '$thiscompound'\n";
#      }
#      if (arrayloc(\@abbreviation,$thiscompound,$totalabbreviations) < 0) {
#         $exccount++;
#         print EXC "$thiscompound was not found in abbreviation list\n";
#      }
#      $newreactiontext = $newreactiontext.$thiscompound;
#   }
    $$fluxreverse_ref{$thisfluxname} = "false";
    $newreactiontext = replacecharacter($reactiontext,"<","&lt;");
    if ($newreactiontext ne $reactiontext) {
        $$fluxreverse_ref{$thisfluxname} = "true";
    }
    $newreactiontext= replacecharacter($newreactiontext,">","&gt;");
    $delimiterloc = index($reactiontext,"-->");
    if ($delimiterloc > 0) {
        $reactantstring = substr($reactiontext,0,$delimiterloc-1);
    }
    else {
        $reactantstring = "";
    }
print "reactantstring is '".$reactantstring."'\n";
    $reactantstring = truncatestring($reactantstring);
print "reactantstring is '".$reactantstring."'\n";
    @reactantcols = split ' \\+ ',$reactantstring;
print "reactant cols are ";
    @reactantnamearray = ();
    @reactcoeffarray = ();
#    @reactdenominatorarray = ();
    for ($i=0; $i<@reactantcols; ++$i) {
print $reactantcols[$i].":";
        if (index($reactantcols[$i]," ") > -1) {
            @reactantpieces = split " ",$reactantcols[$i];
            $reactcoeffarray[$i] = $reactantpieces[0];
#	    $rdelimiterloc = index($reactcoeffarray[$i],".");
#	    if ($rdelimiterloc > -1) {
# print "starting coefficient is ".$reactcoeffarray[$i]."\nperiod location is ".$rdelimiterloc."\n";
#	        $numdecimals = length($reactcoeffarray[$i])-$rdelimiterloc-1;
#	        $reactdenominatorarray[$i] = 10**$numdecimals;
#print "denominator is ".$reactdenominatorarray[$i]."
# ";
#		$reactcoeffarray[$i] = $reactdenominatorarray[$i]*$reactcoeffarray[$i];
#print "numerator is ".$reactcoeffarray[$i]."
#";
#	    }
            $reactantnamearray[$i] = $reactantpieces[1];
        }
        else {
            $reactantnamearray[$i] = $reactantcols[$i];
        }
    }
print "\n";
    if (@reactantnamearray > 0) {
        $$fluxreactants_ref{$thisfluxname} = "            <listOfReactants>\n";
        for ($i=0; $i<@reactantnamearray; ++$i) {
            $reactantnamearray[$i] = prependdigits($reactantnamearray[$i]);
print "reactantnamearray ".$i." is '".$reactantnamearray[$i]."'\n";
print "reactcoeffarray ".$i." is '".$reactcoeffarray[$i]."'\n";
#print "reactdenominatorarray ".$i." is '".$reactdenominatorarray[$i]."'\n";
            if ($reactcoeffarray[$i] eq "") {
                $$fluxreactants_ref{$thisfluxname} = $$fluxreactants_ref{$thisfluxname}.'               <speciesReference species="'.$reactantnamearray[$i].'" stoichiometry="1"';
            }
            else {
                $$fluxreactants_ref{$thisfluxname} = $$fluxreactants_ref{$thisfluxname}.'               <speciesReference species="'.$reactantnamearray[$i].'" stoichiometry="'.$reactcoeffarray[$i].'"';
#	    if ($reactdenominatorarray[$i] ne "") {
#	        $$fluxreactants_ref{$thisfluxname} = $$fluxreactants_ref{$thisfluxname}.' denominator = "'.$reactdenominatorarray[$i].'"';
#	    }
            }
            $$fluxreactants_ref{$thisfluxname} = $$fluxreactants_ref{$thisfluxname}.'/>
';
        }
        $$fluxreactants_ref{$thisfluxname} = $$fluxreactants_ref{$thisfluxname}.'            </listOfReactants>
';
    }
    $productstring = substr($reactiontext,-(length($reactiontext)-$delimiterloc-4));
print "productstring is '".$productstring."'\n";
    $productstring = truncatestring($productstring);
print "productstring is '".$productstring."'\n";
    @productcols = split ' \\+ ',$productstring;
print "product cols are ";
    @productnamearray = ();
    @productcoeffarray = ();
#    @productdenominatorarray = ();
    for ($i=0; $i<@productcols; ++$i) {
print $productcols[$i].":";
        if (index($productcols[$i]," ") > -1) {
            @productpieces = split " ",$productcols[$i];
            $productcoeffarray[$i] = $productpieces[0];
#	    $pdelimiterloc = index($productcoeffarray[$i],".");
#	    if ($pdelimiterloc > -1) {
# print "starting coefficient is ".$productcoeffarray[$i]."\nperiod location is ".$pdelimiterloc."\n";
#                $numdecimals = length($productcoeffarray[$i])-$pdelimiterloc-1;
#		$productdenominatorarray[$i] = 10**$numdecimals;
#print "denominator is ".$productdenominatorarray[$i]."\n";
#                $productcoeffarray[$i] = $productdenominatorarray[$i]*$productcoeffarray[$i];
#print "numerator is ".$productcoeffarray[$i];
#            }
            $productnamearray[$i] = $productpieces[1];
        }
        else {
            $productnamearray[$i] = $productcols[$i];
        }
    }
print "\n";
    $$fluxproducts_ref{$thisfluxname} = "            <listOfProducts>\n";
    for ($i=0; $i<@productnamearray; ++$i) {
        $productnamearray[$i] = prependdigits($productnamearray[$i]);
print "productnamearray ".$i." is '".$productnamearray[$i]."'\n";
print "productcoeffarray ".$i." is '".$productcoeffarray[$i]."'\n";
#print "productdenominatorarray ".$i." is '".$productdenominatorarray[$i]."'\n";
        if ($productcoeffarray[$i] eq "") {
            $$fluxproducts_ref{$thisfluxname} = $$fluxproducts_ref{$thisfluxname}.'               <speciesReference species="'.$productnamearray[$i].'" stoichiometry="1"';
        }
        else {
            $$fluxproducts_ref{$thisfluxname} = $$fluxproducts_ref{$thisfluxname}.'               <speciesReference species="'.$productnamearray[$i].'" stoichiometry="'.$productcoeffarray[$i].'"';
#	    if ($productdenominatorarray[$i] ne "") {
#	        $$fluxproducts_ref{$thisfluxname} = $$fluxproducts_ref{$thisfluxname}.' denominator = "'.$productdenominatorarray[$i].'"';
#	    }
        }
        $$fluxproducts_ref{$thisfluxname} = $$fluxproducts_ref{$thisfluxname}.'/>
';
    }
    $$fluxproducts_ref{$thisfluxname} = $$fluxproducts_ref{$thisfluxname}."            </listOfProducts>
";
    if (@genenames > 0) {
        $$fluxmodifiers_ref{$thisfluxname} = "            <listOfModifiers>\n";
        for ($i=0; $i<@genenames; ++$i) {
print "genename ".$i." is '".$genenames[$i]."'\n";
            $$fluxmodifiers_ref{$thisfluxname} = $$fluxmodifiers_ref{$thisfluxname}.'               <modifierSpeciesReference species="'.$genenames[$i].'"/>
';
        }
        $$fluxmodifiers_ref{$thisfluxname} = $$fluxmodifiers_ref{$thisfluxname}."            </listOfModifiers>
";
    }
    return $newreactiontext;
}

sub processabbreviationfile {

    my $abblist_ref = $_[0];
    my $abbfilename = $_[1];

    open (INABB,$abbfilename);

    my $line = <INABB>;
    my @cols = ();

    while ($line = <INABB>) {
        chomp($line);
        @cols = split "\t",$line;
        $$abblist_ref{$cols[0]} = $cols[1];
    }    

    close (INABB);
}

sub addcompoundspecies {

   local *compoundarray = $_[0];
   my $abblist_ref = $_[1];
   my $compoundlist_ref = $_[2];
   my $i;

   for ($i=0; $i<@compoundarray; ++$i) {
print "addcompoundspecies: checking ".$compoundarray[$i]."\n";      
       if (!exists $$compoundlist_ref{$compoundarray[$i]}) {
# strip initial underscore if necessary
           $thiscompound = $compoundarray[$i];
	   if (index($thiscompound,"13") > -1) {
               print "thiscompound is '".$thiscompound."' with first character '".substr($thiscompound,0,1)."'\n";
	   }
           if (substr($thiscompound,0,1) eq "_") {
               $thiscompound = substr($thiscompound,1);
	   }
	   if (index($thiscompound,"13") > -1) {
               print "now thiscompound is '".$thiscompound."' with first character '".substr($thiscompound,0,1)."'\n";
	   }
           if (exists $$abblist_ref{$thiscompound}) {
               $$compoundlist_ref{$compoundarray[$i]} = $$abblist_ref{$thiscompound};
           }
           else {
               print "WARNING: Compound '".$thiscompound."' was not found in revisedabbreviations.txt\n";
               $$compoundlist_ref{$compoundarray[$i]} = $thiscompound;
           }  
       }
   }
}
sub addmodifierspecies {

   local *genearray = $_[0];
   my $fullname = $_[1];
   my $modifierlist_ref = $_[2];
   my $i;

   for ($i=0; $i<@genearray; ++$i) {
print "addmodifierspecies: checking ".$genearray[$i]."\n";      
       if (!exists $$modifierlist_ref{$genearray[$i]}) {
           $$modifierlist_ref{$genearray[$i]} = $fullname;
       }
       elsif ($$modifierlist_ref{$genearray[$i]} ne $fullname) {
           print "WARNING: Original ".$genearray[$i]." description was ".$$modifierlist_ref{$genearray[$i]}.
              ", but it is now described as ".$fullname."\n";
       }
   }
}
sub arrayloc {

    local *thisarray = $_[0];
    $lookupword = $_[1];
    $arraysize = $_[2];

    $foundindex = -1;

    for ($i=0; $i<@thisarray && $foundindex == -1; ++$i) {

        if ($foundindex < 0) {

            if ($lookupword eq $thisarray[$i]) {

                $foundindex = $i;
            }

        }

    }

    return $foundindex;

}

sub replacecharacter {

    my $fullstring  = $_[0];
    my $lookupchar = $_[1];
    my $newstring = $_[2];

    print "original fullstring is "."'".$fullstring."'\n";

    $firstcharloc = index($fullstring,$lookupchar);
#    print "first location is $firstcharloc\n";
    if ($firstcharloc > -1) {
        $newfullstring = substr($fullstring,0,$firstcharloc);
        print "new fullstring is "."'".$newfullstring."'\n";
        $newfullstring = $newfullstring.$newstring.substr($fullstring,$firstcharloc+1);
    }
    else {
        $newfullstring = $fullstring;
    }

    print "new fullstring is "."'".$newfullstring."'\n";

    return $newfullstring;

}
    
sub prependdigits {

    my $fullstring  = $_[0];

    print "original compound abbreviation is "."'".$fullstring."'\n";

    $firstchar = substr($fullstring,0,1);
    print "firstchar is '".$firstchar."'\n";
    if ($firstchar lt  "0" || $firstchar gt "9") {
        $newfullstring =$fullstring;
    }
    else {
        $newfullstring = "_".$fullstring;
    }

    print "new compound abbreviation is "."'".$newfullstring."'\n";

    return $newfullstring;

}
    
sub truncatestring {

    my $fullstring  = $_[0];

    my $newstring = $fullstring;

    print "original fullstring is "."'".$fullstring."'\n";

    while (substr($newstring,-1) eq " ") {
        $newstring = substr($newstring,0,length($newstring)-1);
    }

    print "new string is "."'".$newstring."'\n";

    return $newstring;

}
    
sub writefilestart {

    print OUT '<?xml version="1.0"?>
<sbml xmlns="http://www.sbml.org/sbml/level2" version="1" level="2">
   <model id="Ecolimostimportantfluxes" name="The most important fluxes in the original E coli flux model used by the original MOMA application.">
      <notes>
         <body xmlns="http://www.w3.org/1999/xhtml">
';

}
