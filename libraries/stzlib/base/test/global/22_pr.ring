# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #22.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? @@([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])
#--> [
#	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
#	"4", "4*", "4*3", "4*34", "*", "*3",
#	"*34", "3", "34", "4"
# ]

pf()
# Executed in 0.05 second(s)
