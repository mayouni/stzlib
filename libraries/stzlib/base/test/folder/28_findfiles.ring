# Narrative
# --------
#
# Extracted from stzfoldertest.ring, block #28.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzFolder("C:\TestArea")

? @@( o1.FindFiles(["test.txt"]) )
#--> [ "test.txt" ]

? @@NL( o1.FindFiles("*.txt") )
#-->
'
[
	"../Images/image1.png",
	"../Images/image2.png",
	"../Images/notes/howto.txt",
	"../Images/notes/sources.txt",
	"../tempo/temp1.txt",
	"../tempo/temp2.txt",
	"../test.txt"
]
'
? @@NL( o1.FindFolders("*m*") )
#-->
'[
	"../Images/",
	"../Images/more/",
	"../Music/",
	"../tempo/"
]'

/*
FindFolders
SearchFolders

Find
Search
*/



pf()
# Executed in 0.07 second(s) in Ring 1.22
