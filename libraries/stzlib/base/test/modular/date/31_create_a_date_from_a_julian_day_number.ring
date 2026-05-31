# Narrative
# --------
# Create a date from a Julian day number
#
# Extracted from stzdatetest.ring, block #31.

load "../../../stzBase.ring"


pr()

o1 = new stzDate("")
o1.FromJulianDay(2460959)
? o1.Content()
#--> 16/09/2024	(the corresponding Gregorian date)

pf()
# Executed in almost 0 second(s) in Ring 1.24
