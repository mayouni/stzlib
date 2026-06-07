# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #661.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

o1 = new stzString("...ONE...NONE...SONY...")

? o1.CountInSections("N", [ [3, 5], [9, 12], [16, 19] ])
#--> 4

? @@ ( o1.FindInSections("N", [ [3, 5], [9, 12], [16, 19] ]) ) + NL
#--> [ 5, 10, 12, 19 ]

# Same functions work for lists

o1 = new stzList([
	".", ".", ".",
	"O", "N", "E",
	".", ".", ".",
	"N", "O", "N", "E",
	".", ".", ".",
	"S", "O", "N", "Y",
	".", ".", "."
])

? o1.CountInSections("N", [ [3, 5], [9, 12], [16, 19] ])
#--> 4

? @@ ( o1.FindInSections("N", [ [3, 5], [9, 12], [16, 19] ]) )

pf()
# Executed in 0.04 second(s)
