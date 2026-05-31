# Narrative
# --------
# Short and long folders and files names
#
# Extracted from stzfoldertest.ring, block #20.

load "../../../stzBase.ring"


pr()

o1 = new stzFolder("c:/testarea")

# This method returns the folder original path

? o1.Path()	# Or Home() or Root() or Folder()
#--> c:/testarea

# The name itself is just the name of the folder
# without any path noise

? o1.Name() + NL
#--> testarea

# Now, Softanza enforces a convention when listing
# folders and files. Folders always start with "/"
# and end with "/"

? @@NL( o1.Folders() )
#-->
'
[
	"/docs/",
	"/images/",
	"/more/",
	"/music/",
	"/notes/",
	"/tempo/",
	"/videos/"
]
'
# And you can add the long paths with XT()

? @@NL( o1.FoldersXT() )
#-->
'
[
	"c:/testarea/docs/",
	"c:/testarea/images/",
	"c:/testarea/more/",
	"c:/testarea/music/",
	"c:/testarea/notes/",
	"c:/testarea/tempo/",
	"c:/testarea/videos/"
]
'

# While files start with "/" but does not end with an "/"
# Let's see it in the full lis tof files at any level
# of the folder tree (using Deep prefix)

? @@NL( o1.DeepFiles() )
#-->
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

# This convention make folders distinsguishable from folders

# Similarilty you can list the files with their long paths+names

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
