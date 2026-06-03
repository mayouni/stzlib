# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #612.
#ERR Error (R14) : Calling Method without definition: checkw

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])

? o1.CheckW("isString(This[@i]) and @IsUppercase(This[@i])")
#--> TRUE

pf()
# Executed in 0.09 second(s) in Ring 1.22
