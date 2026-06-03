# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #165.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.ToCode()

pf()
# Executed in 0.05 second(s)
