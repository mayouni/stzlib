# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #9.

load "../../../stzBase.ring"


aLists = [
	[ "mohannad", 	100, 	"him", 	"ring" ],
	[ "karim", 	20, 	"hi", 	"" ],
	[ "salem", 	67, 	"", 	"" ],
	[ "mazen", 	0, 	"X", 	1 ],
	[ "mourad", 	18, 	"", 	"" ],
	[ "abir", 	0, 	"", 	"" ],
	[ "amer", 	34, 	"[ ]", 	"" ]
]

? @@NL( ring_sort2(aLists, 2) )
#--> [
#	[ "mazen", 0, "X", 1 ],
#	[ "abir", 0, "", "" ],
#	[ "mourad", 18, "", "" ],
#	[ "karim", 20, "hi", "" ],
#	[ "amer", 34, "[ ]", "" ],
#	[ "salem", 67, "", "" ],
#	[ "mohannad", 100, "him", "ring" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
