# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #154.

load "../../stzBase.ring"

pr()

o1 = new stzString("..3..♥..♥..2..")
? o1.FindInSection("♥", 3, 12)
#--> [6, 9]

? o1.FindInSection("♥", 12, 3)
#--> [6, 9]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.06 second(s) in Ring 1.18
