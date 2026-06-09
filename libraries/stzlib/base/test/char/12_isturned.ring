# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #12.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("Ɯ")
? o1.IsTurned()
#--> TRUE

? o1.IsTurnable()
#--> TRUE

? o1.Turned()
#--> M

#--

o1 = new stzChar("M")
? o1.IsTurned()
#--> FALSE

? o1.IsTurnable()
#--> TRUE

? o1.Turned()
#--> Ɯ

pf()
# Executed in 0.08 second(s) in Ring 1.23
# Executed in 0.22 second(s) in Ring 1.207
