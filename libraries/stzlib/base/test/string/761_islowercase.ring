# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #761.

load "../../stzBase.ring"

pr()

o1 = new stzString("happy-holidays")

? o1.IsLowercase()
#--> TRUE

o1 = new stzString("HOLIDAYS!")
? o1.IsUppercase()
#--> TRUE

pf()
# Executed in 0.04 second(s).
