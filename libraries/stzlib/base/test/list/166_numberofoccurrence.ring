# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #166.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", '"*"', "3", "34", "4", '"*"'
])

? o1.NumberOfOccurrence('"*"')
#--> 3

? o1.Find('"*"')
#--> [2, 14, 18]

pf()
# Executed in 0.15 second(s)
