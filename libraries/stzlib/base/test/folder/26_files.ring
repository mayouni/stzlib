# Narrative
# --------
# pr()
#
# Extracted from stzfoldertest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzFolder("c:/testarea")

# Geetting the files at the root with a simplified path
? @@( o1.Files() )
#--> [ "/test.txt" ]

# The same thing but with complete path

? @@( o1.FilesXT() )
#--> [ "c:/testarea/test.txt" ]

# Now we check the list of all files at any level

? @@NL( o1.DeepFiles() )
#--> a list of simlified paths
'
[
	"/test.txt",
	"/Images/image1.png",
	"/Images/image2.png",
	"/tempo/temp1.txt",
	"/tempo/temp2.txt",
	"/Images/notes/howto.txt",
	"/Images/notes/sources.txt"
]
'

# We add the XT extension and we get files with full path

? @@NL( o1.DeepFilesXT() )
#-->
'
[
	"c:/testarea/test.txt",
	"c:/testarea/Images/image1.png",
	"c:/testarea/Images/image2.png",
	"c:/testarea/tempo/temp1.txt",
	"c:/testarea/tempo/temp2.txt",
	"c:/testarea/Images/notes/howto.txt",
	"c:/testarea/Images/notes/sources.txt"
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
