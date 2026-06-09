# Narrative
# --------
# Convert current date to Julian day number
#
# Extracted from stzdatetest.ring, block #30.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzDate("2025-10-10")
? o1.ToJulianDay()
#--> 2460959

pf()
# Executed in almost 0 second(s) in Ring 1.24
