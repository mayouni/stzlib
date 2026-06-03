# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #19.

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

# Now, let’s sort this complex structure based on the 3rd column of each list (index 3).

? @@NL( o1.SortedOn(3) )

#--> [
#	[ "salem", 67, "", "" ],
#	[ "mourad", 18, "", "" ],
#	[ "abir", 234, "", "" ],
#	[ "abir", "", "", "" ],
#	[ "abir", "", "", "" ],
#	[ "mazen", [ 90 ], "X", 1 ],
#	[ "amer", 34, "[ 1, 2, 3 ]", "" ],
#	[ "sahloul", 108, "amer", 34 ],
#	[ "karim", 20, "amer", 34 ],
#	[ "mohannad", 100, "him", "ring" ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
