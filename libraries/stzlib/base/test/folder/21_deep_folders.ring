# Narrative
# --------
# Listing folders at every level (DeepFolders)
#
# Extracted from stzfoldertest.ring, block #21.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t21"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
? @@NL( o1.DeepFolders() )
#-->
'
[
	"/docs/",
	"/images/",
	"/music/",
	"/tempo/",
	"/videos/",
	"/images/more/",
	"/images/notes/"
]
'

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
