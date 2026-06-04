# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #263.
#ERR exit 1

load "../../stzBase.ring"

pr()

o1 = new stzCCode("isNumber(0+ @item)")
o1.Transpile()
? o1.Content()
#--> isnumber( 0+  this[@i]  )

pf()
# Executed in 0.06 second(s) in Ring 1.22
