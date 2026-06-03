# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #104.

load "../../stzBase.ring"

pr()

o1 = new stzString("123♥♥678♥♥1234♥♥789")

? o1.ContainsInSection("♥", 3, 10)
#--> TRUE

? o1.ContainsInSections("♥", [ [3,10], [8,12], [14,19] ])
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
