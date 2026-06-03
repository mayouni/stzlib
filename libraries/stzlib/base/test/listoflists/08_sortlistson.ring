# Narrative
# --------
# #narration
#
# Extracted from stzlistofliststest.ring, block #8.

load "../../stzBase.ring"


pr()

# Softanza can gracefully sort a list of lists on a given column,
# even when these inner lists exhibit varying lengths

aLists = [
	[ "mohannad", 	100, 	"him", 	"ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "salem", 	18 ],
	[ "mazen", 	300, 	"X", 	1 ],
	[ "amer", 	300, 	"a", 	1 ],
	[ "mourad", 	18 ],
	[ "abir" ],
	[ "amer", 	34, 	[] ],
	[ "amer", 	20, 	"" ]
]

? @@NL( SortListsOn(aLists, 3) )
#--> [
#	[ "abir", 	"", 	"", 	"" 	],
#	[ "mourad", 	18, 	"", 	"" 	],
#	[ "salem", 	18, 	"", 	"" 	],
#	[ "amer", 	20, 	"", 	"" 	],
#	[ "mazen", 	300, 	"X", 	1 	],
#	[ "amer", 	34, 	"[]", 	"" 	],
#	[ "amer", 	300, 	"a", 	1 	],
#	[ "karim", 	20, 	"hi", 	"" 	],
#	[ "mohannad", 	100, 	"him", 	"ring" 	]
# ]

# As you can see, the list is sorted with two notable modifications:
# all the lists are adjusted to the lengh of the largest list
# using NULLs, and if the nth column contains lists then those
# lists are stringified.

# These modifications are made to make it possible the use of
# the Ring standard function sort(aListOfLists, nCol).

pf()
# Executed in 0.02 second(s) in Ring 1.21
