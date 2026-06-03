# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #18.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"amer", 34 ],
	[ "abir",	234 ],
	[ "salem", 	67 ],
	[ "mazen", 	[90], 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[1, 2, 3 ] ],
	[ "sahloul",	108, 	"amer",	34 ],
	[ "abir" ]
])

? Q([ "sahloul", 108, "amer", 34 ]).FindSubList([ "amer", 34 ])
#--> [ 3, 4 ]

? @@NL( o1.FindSubList([ "amer", 34 ]) ) + NL
#--> [
#	[ 2, [ 3, 4 ] ],
#	[ 8, [ 1, 2 ] ],
#	[ 9, [ 3, 4 ] ]
# ]

? o1.ContainsSubList([ "amer", 34 ])
#--> TRUE

pf()
# Executed in 0.11 second(s) in Ring 1.21
