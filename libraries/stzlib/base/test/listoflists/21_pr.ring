# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #21.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "mohannad", 	100, 	"him", 		"ring" 	],
	[ "karim", 	20 , 	[ 89, 14, 10 ] 		],
	[ "salem", 	67 , 	"h" 			],
	[ "hatem",	1200, 	[ "xyz", "www" ] 	],
	[ "selim",	199, 	1500			]
])


? @@NL( o1.SortedOn(3) )
#--> [
#	[ "selim", 199,    1500 			],
#	[ "hatem", 1200,   [ "xyz", "www" ] 		],
#	[ "karim", 20,     [ 89, 14, 10 ] 		],
#	[ "salem", 67,     "h" 				],
#	[ "mohannad", 100, "him", 		"ring" 	]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
