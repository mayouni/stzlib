# Narrative
# --------
# Files, FilesXT, DeepFiles, DeepFilesXT
#
# Extracted from stzfoldertest.ring, block #26.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t26"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

# Files at the root with a simplified path
? @@( o1.Files() )
#--> [ "/test.txt" ]

# The same with the complete path
? @@( o1.FilesXT() )
#--> [ "<testarea>/test.txt" ]

# All files at every level (simplified paths)
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

# The same files with full paths (XT)
? @@NL( o1.DeepFilesXT() )
#--> the same deep files, each prefixed with the full <testarea> path

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
