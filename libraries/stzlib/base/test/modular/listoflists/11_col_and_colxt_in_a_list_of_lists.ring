# Narrative
# --------
# Col() and ColXT() in a list of lists
#
# Extracted from stzlistofliststest.ring, block #11.

load "../../../stzBase.ring"


pr()

o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "salem", 	67 ],
	[ "mazen", 	90, 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[] ]
])

? @@NL( o1.Col(3) ) + NL
#--> [
#	"him",
#	"hi",
#	"X",
#	[ ]
# ]

# ColXT adds NULLs to lines corresponding to inner lists
# with smaller size then n

? @@NL( o1.ColXT(3) )
#--> [
#	"him",
#	"hi",
#	"",
#	"X",
#	"",
#	"",
#	[ ]
# ]

pf()
# Executed in 0.02 second(s).
