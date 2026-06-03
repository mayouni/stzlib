# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #164.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"*", '"*"', "*4", [ "A", "B" , "'C'"], 12
])

? o1.ToCode()
#--> [ "*", '"*"', "*4", [ "A", "B", "'C'" ], 12 ]

pf()
# Executed in 0.04 second(s)
