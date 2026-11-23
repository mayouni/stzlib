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
# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
? @@NL( o1.DeepFolders() )
#--> [
#--> "/docs/",
#--> "/images/",
#--> "/music/",
#--> "/tempo/",
#--> "/videos/",
#--> "/images/more/",
#--> "/images/notes/"
#--> ]
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

RemoveTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
