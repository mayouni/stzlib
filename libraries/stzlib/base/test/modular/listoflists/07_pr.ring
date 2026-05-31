# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #7.

load "../../../stzBase.ring"


aLists = [
	[ "mohannad", 	100, 	"him", 	"ring" ],
	[ "karim", 	20,   	"hi" ],
	[ "salem", 	18 ],
	[ "mazen", 	300, 	"X", 	1 ],
	[ "amer", 	300, 	"a", 	1 ],
	[ "mourad", 	18 ],
	[ "abir" ],
	[ "amer", 	34, 	'[]' ],
	[ "amer", 	20, 	"" ],
	[ "mahran", 	87,	FalseObject() ]
]

SortListsOn(aLists, 3)
#--> ERROR: Can't proceed! Nth column must not contain objects.

pf()
