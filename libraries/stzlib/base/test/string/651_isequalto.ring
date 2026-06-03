# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #651.

load "../../stzBase.ring"

pr()

o1 = new stzString("ritekode")

? o1.IsEqualTo("ritekode")
#--> TRUE

? o1.IsEqualToCS("RiteKode", :CS = FALSE)
#--> TRUE

? o1.IsEqualToCS("RiteKode", TRUE)
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.18
