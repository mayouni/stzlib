# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #530.

load "../../stzBase.ring"

pr()

o1 = new stzString("what a <<nice>>> day!")

? o1.Section(8, 9)
#--> "<<"
? o1.Section(14, 16) + NL
#--> ">>>"

? o1.Sections([ [8, 9], [14, 16] ])
#--> [ "<<", ">>>" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
