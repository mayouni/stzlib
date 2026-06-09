# Narrative
# --------
# pr()
#
# Extracted from stzfoldertest.ring, block #22.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzFolder("c:/testarea")
o1.DeepExpandFolder("/images")
? o1.Show()

? o1.IsDeepFolder("/images/notes/")
#--> TRUE

? o1.DeepExists("/images/notes/")
#--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.22
