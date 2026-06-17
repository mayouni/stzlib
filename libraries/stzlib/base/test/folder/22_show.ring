# Narrative
# --------
# Showing a tree with one branch deep-expanded
#
# Extracted from stzfoldertest.ring, block #22.
# Portable: runs against the local testarea fixture.

load "../../stzBase.ring"
load "_fixture.ring"

pr()

cTA = CurrentDir() + "/_t22"
BuildTestArea(cTA)

o1 = new stzFolder(cTA)
o1.DeepExpandFolder("/images")
? o1.Show()
#--> the tree with the images branch (and its sub-folders) expanded

? o1.IsDeepFolder("/images/notes/")
#--> 1

? o1.DeepExists("/images/notes/")
#--> 1

KillTestArea(cTA)

pf()
# Executed in 0.01 second(s) in Ring 1.23
