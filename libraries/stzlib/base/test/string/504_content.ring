# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #504.

load "../../stzBase.ring"

pr()

o1 = new stzString("SOooooFTAaaannnNZA")
o1.RemoveWXT('Q(@char).isLowercase()') # remove all lowercase characters

? o1.Content()
#--> "SOFTANZA"

pf()
# Executed in 0.24 second(s) in Ring 1.22
