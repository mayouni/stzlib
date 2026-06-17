# Narrative
# --------
# Short and long folders and files names
#
# Extracted from stzfoldertest.ring, block #20.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t20"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

# The folder's own path (real case preserved)

? o1.Path()	# Or Home() or Root() or Folder()
#--> <testarea>

# The name is just the folder's name without any path noise

? o1.Name()
#--> _t20

# Softanza enforces a listing convention: folders always start with "/"
# and end with "/", and child names are presented in lowercase.

? @@NL( o1.Folders() )
#-->
'
[
	"/docs/",
	"/images/",
	"/music/",
	"/tempo/",
	"/videos/"
]
'
# And you get the long paths with the XT() variant

? @@NL( o1.FoldersXT() )
#--> the same folders, each prefixed with the full <testarea> path

# Files start with "/" but do NOT end with "/". Here is the full list of
# files at every level of the tree (Deep prefix):

? @@NL( o1.DeepFiles() )
#-->
'
[
	"/test.txt",
	"/images/image1.png",
	"/images/image2.png",
	"/tempo/temp1.txt",
	"/tempo/temp2.txt",
	"/images/notes/howto.txt",
	"/images/notes/sources.txt"
]
'
# Similarly, the files with their long paths+names

? @@NL( o1.DeepFilesXT() )
#--> the same deep files, each prefixed with the full <testarea> path

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
