# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #17.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", "ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "abir",	234 ],
	[ "salem", 	67 ],
	[ "mazen", 	[90], 	"X", 1 ],
	[ "mourad",	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[1, 2, 3 ] ],
	[ "sahloul",	108, 	"amer",	34 ],
	[ "abir" ]
])


? @@NL( o1.ListsWXT(' Q(@list).Contains("abir") ') ) + NL
#--> [
#	[ "abir", 234 ],
#	[ "abir" ],
#	[ "abir" ]
# ]

? o1.FindListsWXT(' Q(@list).Contains("abir") ')
#--> [ 3, 7, 9 ]

? @@NL( o1.ListsWXTZ(' Q(@list).Contains("abir") ') ) + NL
#--> [
#	[ [ "abir", 234 ], 3 ],
#	[ [ "abir" ], 	   7 ],
#	[ [ "abir" ], 	   9 ]
# ]

? @@NL( o1.ListsWXTZ(' Q(@list).ContainsMany([ "amer", 34 ]) ') ) + NL
#--> [
#	[ [ "amer", 34, [ 1, 2, 3 ] ], 8 ],
#	[ [ "sahloul", 108, "amer", 34 ], 9 ]
# ]

pf()
# Executed in 0.20 second(s) in Ring 1.21
