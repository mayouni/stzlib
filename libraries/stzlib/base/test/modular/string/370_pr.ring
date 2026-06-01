# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #370.

load "../../../stzBase.ring"


? Q(:IsBoundedBy = ".").IsIsBoundedByNamedParam()
#--> TRUE

? Q(".♥.").SubStringIsBoundedBy("♥", ".")
#--> TRUE

? Q(".♥.").SubStringXT("♥", :IsBoundedBy = ".")
#--> TRUE

pf()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.18
