# Narrative
# --------
# CHECKER
#
# Extracted from stzlisttest.ring, block #610.
#ERR Error (R14) : Calling Method without definition: containsw

load "../../stzBase.ring"


pr()

o1 = new stzList([ "A", "B", "C", 5 ])

? o1.ContainsW("isString(This[@i]) and @IsUppercase(This[@i])")

pf()
# Executed in 0.04 second(s) in Ring 1.22
