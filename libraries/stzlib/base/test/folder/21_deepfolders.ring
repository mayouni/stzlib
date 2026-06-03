# Narrative
# --------
# pr()
#
# Extracted from stzfoldertest.ring, block #21.

load "../../stzBase.ring"

pr()

o1 = new stzFolder("c:/testarea")
? @@NL( o1.DeepFolders() )

pf()
