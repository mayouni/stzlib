# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #611.
#ERR Error (R14) : Calling Method without definition: checkw

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 5, "B", "C" ])

? o1.CheckW("isString(This[@i]) and @IsUppercase(This[@i])")
#--> FALSE

pf()
# Executed in 0.10 second(s) in Ring 1.22
