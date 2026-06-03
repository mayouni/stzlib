# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #596.

load "../../stzBase.ring"


o1 = new stzString("Baba, Mama, and Dada")
? o1.ContainsOneOfTheseCS([ "Mom", "mama" ], :CaseSensitive = FALSE)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
