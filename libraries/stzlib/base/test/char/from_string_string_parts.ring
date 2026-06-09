# Narrative
# --------
# STRING PARTS ===========
#
# Extracted from stzStringTest.ring, block #732.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@(o1.PartsUsingXT('StzCharQ(@char).CharCase()')) + NL # or simply o1.PartsUsing('StzCharQ(@char)')
# [
#	"H",
#	"anine",
#o	" حنين ",
#	"is",
#	" ",
#	"a",
#	" ",
#	"nice",
#o	" جميلة وعمرها 7 ",
#	"years",
#	"-",
#	"old",
#o	" سنوات ",
#	"girl",
#	"!"
# ]

? @@NL( o1.PartsAndPartitionersUsingXT('StzCharQ(@char).CharCase()') ) + NL # or Parts2UsingXT()
#--> [
#	[ "H", 			"uppercase" 	],
#	[ "anine", 		"lowercase" 	],
#o	[ " حنين ", 		"" 		],
#	[ "is", 		"lowercase" 	],
#	[ " ", 			"" 		],
#	[ "a", 			"lowercase" 	],
#	[ " ", 			"" 		],
#	[ "nice", 		"lowercase" 	],
#o	[ " جميلة وعمرها 7 ", 	"" 	],
#	[ "years", 		"lowercase" 	],
#	[ "-", 			"" 		],
#	[ "old", 		"lowercase" 	],
#o	[ " سنوات ", 		"" 		],
#	[ "girl", 		"lowercase" 	],
#	[ "!", 			"" 		]
# ]

? @@NL( o1.PartitionersAndPartsUsingXT('StzCharQ(@char).CharCase()') ) 
#--> [
#	[ "uppercase", 		"H" 			],
#	[ "lowercase", 		"anine" 		],
#o	[ "", 			" حنين " 		],
#	[ "lowercase", 		"is" 			],
#	[ "", 			" " 			],
#	[ "lowercase", 		"a" 			],
#	[ "", 			" " 			],
#	[ "lowercase", 		"nice" 			],
#o	[ "", 			" جميلة وعمرها 7 " 	],
#	[ "lowercase", 		"years" 		],
#	[ "", 			"-" 			],
#	[ "lowercase", 		"old" 			],
#o	[ "", 			" سنوات " 		],
#	[ "lowercase", 		"girl" 			],
#	[ "", 			"!" 			]
# ]

pf()
# Executed in 0.92 second(s).
