# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #507.
#ERR Error (R14) : Calling Method without definition: containsmorethenn

load "../../stzBase.ring"

pr()

o1 = new stzString("ab_cd_ef_gh")

? o1.ContainsMoreThenN(1, "_")
#--> TRUE

? o1.ContainsMoreThenN(1, "a")
#--> FALSE

? o1.ContainsNTimes(1, "a")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
