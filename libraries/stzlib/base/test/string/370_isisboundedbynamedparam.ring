# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #370.
#ERR Error (R14) : Calling Method without definition: substringisboundedby

load "../../stzBase.ring"

pr()

? Q(:IsBoundedBy = ".").IsIsBoundedByNamedParam()
#--> TRUE

? Q(".♥.").SubStringIsBoundedBy("♥", ".")
#--> TRUE

? Q(".♥.").SubStringXT("♥", :IsBoundedBy = ".")
#--> TRUE

pf()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.18
