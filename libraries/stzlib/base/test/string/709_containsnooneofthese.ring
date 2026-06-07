# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #709.

load "../../stzBase.ring"

pr()

o1 = new stzString("abcdef")

? o1.ContainsNoOneOfThese([ "xy", "xyz", "mwb" ])
#--> TRUE

? o1.ContainsNoOneOfThese([ "xy", "xyz", "de", "mwb" ])
#--> FALSE

pf()
# Executed in 0.01 second(s).
