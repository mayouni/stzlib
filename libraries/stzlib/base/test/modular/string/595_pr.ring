# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #595.

load "../../../stzBase.ring"


o1 = new stzString("@str = Q(@str).Uppercased()")

? o1.BeginsWithOneOfTheseCS([ "@str =", :Or = "@str=" ], TRUE)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
