# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #51.

load "../../stzBase.ring"

pr()

o1 = new stzNumber("12.872")

? o1.IsEqual(12.872)
#--> TRUE

? o1.IsBetween(12, "13")
#--> TRUE

pf()
# Executed in 0.06 second(s)
