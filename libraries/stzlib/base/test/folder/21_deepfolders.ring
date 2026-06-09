# Narrative
# --------
# pr()
#
# Extracted from stzfoldertest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzFolder("c:/testarea")
? @@NL( o1.DeepFolders() )

pf()
