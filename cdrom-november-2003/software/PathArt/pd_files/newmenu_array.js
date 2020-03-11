timegap=500
followspeed=5
followrate=30
suboffset_top=10;
suboffset_left=10;

effect = "fade(duration=0.3);Shadow(color='#777777', Direction=135, Strength=5)"

function openwin(url)
{
	nwin=window.open(url, "nwin",config="scrollbars=yes,resizable=yes,toolbar=yes,location=yes,status=yes,menubar=yes,");
	nwin.focus();
}

prop1=[			  			        // prop1 is an array of properties you can have as many property arrays as you need
"000000",					        // Off Font Color
"A1D050",					        // Off Back Color
"ffffff",					        // On Font Color
"0F187F",					        // On Back Color
"3F486F",					        // Border Color
12,							// Font Size
"normal",					        // Font Style 
"normal",					        // Font Weight
"Verdana,Tahoma,Helvetica,arial",	// Font
4,							        // Padding
"arrow.gif",			         	// Sub Menu Image
0,							        // 3D Border & Separator
"66ffff",				            // 3D High Color
"000099",					        // 3D Low Color
"000000",					        // Referer item Font Color (leave this blank to disable)
"809F4F",					        // Referer item Back Color (leave this blank to disable)
]

menu1=[				// This is the array that contains your menu properties and details
88,				// Top
200,				// left
,					// Width
0,					// Border Width
"left", 			// Screen Position - here you can use "center;middle;right"
prop1,				// Properties Array - this is set higher up, as above
1,					// Always Visible - allows the menu item to be visible at all time
"center",			// Alignment - sets the menu elements alignment, HTML values are valid here for example: left, right or center
,					// Filter - Text variable for setting transitional effects on menu activation
,					// Follow Scrolling - Tells the menu item to follow the user down the screen
1, 					// Horizontal Menu - Tells the menu to be horizontal instead of top to bottom style
,					// Keep Alive - Keeps the menu visible until the user moves over another menu or clicks elsewhere on the page
,					// Position of sub image left:center:right:middle:top:bottom
,					// Show an image on top menu bars indicating a sub menu exists below
,					// Reserved for future use

"Home&nbsp;&nbsp;","index.htm",,"#",1,// "Description Text", "URL", "Alternate URL", "Status", "Separator Bar"
"About&nbsp;us&nbsp;","show-menu2","abt.htm","#",1,
"Services&nbsp;&nbsp;","show-menu5","ser.htm","#",1,
"Products&nbsp;&nbsp;","show-menu3","products.htm","#",1,
"Careers&nbsp;&nbsp;","careers.htm",,"#",1,
"Clients&nbsp;&nbsp;","clients.htm",,"#",1,
"News&nbsp;&&nbsp;Events&nbsp;&nbsp;","news.htm",,"#",1,
"Contact&nbsp;us&nbsp;&nbsp;","cont.htm",,"#",1
]
menu2=[
,,160,1,"",prop1,,"left",effect,,,,,,,
"Mission","mis.htm",,,1,
"Executive Profiles","team.htm",,,1,
"Board of Directors","bod.htm",,,1,
"Scientific Advisory Board ","adv.htm",,,1,
"Facilities","fac.htm",,,1
]
menu3=[,,220,1,,prop1,0,"left",effect,0,,,,,,
"Kinase ChemBioBase<sup>©</sup>","kc.htm",,,1,
"PathArt-Pathway Articulator","pd.htm",,,1,
"GPCR Annotator","ga.htm",,,1,
"Other Small Molecule Databases","osmd.htm",,,1,
"Nitrilase and Nitrile Hydratase Knowledgebase","nnhk.htm",,,1


]
menu4=[
,,166,1,"",prop1,,"",effect,,,,,,,
"Events", "eve.htm",,,1,
"Press Releases", "prl.htm",,,1,
"Press Coverages", "pc.htm",,,1,
"Presentations", "pub.htm",,,1
] 
menu5=[
,,180,1,"",prop1,,"",effect,,,,,,,
"Custom Curation Services", "show-menu6","cc.htm","#",1,
"IT Services", "show-menu7","it.htm","#",1
]
menu6=[
,,170,1,"",prop1,,"",effect,,,,,,,
"Ligand-centric databases", "cc.htm#ld",,,1,
"Gene/Protein-centric databases", "cc.htm#gd",,,1,
"Pathway databases", "cc.htm#pd",,,1,
"Curation Process", "cp.htm",,,1
]
menu7=[
,,170,1,"",prop1,,"",effect,,,,,,,
"Database integration services", "it.htm#dis",,,1,
"Custom application development", "it.htm#cad",,,1,
"Front end design", "it.htm#fd",,,1
]