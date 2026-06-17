# Narrative
# --------
# Visual Finding
#
# Extracted from stzfoldertest.ring, block #29.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t29"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)

# Visual deep-search for png images
? o1.VizDeepSearch("*.png") + NL
#--> a tree marking the two png files deep under images/, with a
#    target stat label at the root.

# Visual search for folders whose name contains 'i'
? o1.VizSearchFolders("*i*")
#--> a tree highlighting folders whose name contains 'i' (images, videos)

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
