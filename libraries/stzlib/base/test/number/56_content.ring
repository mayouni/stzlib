# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #56.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzNumber(-123)
o1.RoundTo(3)
#--> "-123.000"

? o1.Content()

pf()
