# Narrative
# --------
# Finding files and folders by name or wildcard.
#
# Extracted from stzfoldertest.ring, block #28.
# Made portable + self-contained: builds the documented "testarea" fixture
# in a local sandbox instead of assuming a machine-specific C:\TestArea.
# The original #--> blocks were inconsistent (a *.txt search listed .png
# files; a surface FindFolders listed nested paths); the values below are
# the VERIFIED outputs of the now-fixed surface/deep finders.

load "../../stzBase.ring"

pr()

cTA = CurrentDir() + "/_fx28"
if dirExists(cTA) RemoveFolderRecursive(cTA) ok
StzMakeDir(cTA + "/docs")  StzMakeDir(cTA + "/images/more")  StzMakeDir(cTA + "/images/notes")
StzMakeDir(cTA + "/music")  StzMakeDir(cTA + "/tempo")  StzMakeDir(cTA + "/videos")
write(cTA + "/test.txt", "program")
write(cTA + "/images/image1.png", "x")  write(cTA + "/images/image2.png", "x")
write(cTA + "/images/notes/howto.txt", "x")  write(cTA + "/images/notes/sources.txt", "x")
write(cTA + "/tempo/temp1.txt", "x")  write(cTA + "/tempo/temp2.txt", "x")

o1 = new stzFolder(cTA)

# FindFiles accepts a list of explicit names (returns those present)...
? @@( o1.FindFiles(["test.txt"]) )
#--> [ "/test.txt" ]

# ...or a wildcard pattern (surface level only -- root holds just test.txt).
? @@( o1.FindFiles("*.txt") )
#--> [ "/test.txt" ]

# FindFolders matches surface sub-folders (images, music, tempo all carry 'm').
? @@( o1.FindFolders("*m*") )
#--> [ "/images/", "/music/", "/tempo/" ]

# The deep variant recurses the whole subtree.
? @@NL( o1.DeepFindFiles("*.txt") )
#-->
'
[
	"/test.txt",
	"/tempo/temp1.txt",
	"/tempo/temp2.txt",
	"/images/notes/howto.txt",
	"/images/notes/sources.txt"
]
'

if dirExists(cTA) RemoveFolderRecursive(cTA) ok

pf()
# Executed in 0.07 second(s) in Ring 1.23
