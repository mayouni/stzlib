# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #70.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("ح")
? o1.ScriptIs(:Arabic) #--> TRUE
? o1.IsArabicScript()  #--> TRUE

o1 = new stzChar("j")
? o1.ScriptIs(:Latin) #--> TRUE
? o1.IsLatinScript()  #--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
