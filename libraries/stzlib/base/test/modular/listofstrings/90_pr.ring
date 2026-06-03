# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #90.

load "../../../stzBase.ring"


o1 = new stzList([
	"TuNIS", "Tunis", "TUNIS", "TUNIS",
	"gatufsa", "tunis", "tunis",
	"gabes", "Tunis", "Tunis",
	"regueb", "tuta", "regueb", "tunis" ])

? @@(o1.FindAll("tunis"))
#--> [ 6, 7, 14 ]

? @@(o1.FindAllCS("tunis", TRUE))
#--> [ 6, 7, 14 ]

? @@( o1.FindAllCS("tunis", :cs = FALSE) )
#--> [ 1, 2, 3, 4, 6, 7, 9, 10, 14 ]

pf()
# Executed in 0.02 second(s).

/* =================== MANAGING DUPLICATED STRINGS
*/
pr()

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])


? o1.ContainsDuplicatedItems() + NL
#--> TRUE
# Executed in 0.10 second(s)

	//? o1.NumberOfDuplicatedItems()

? @@( o1.DuplicatedItems() ) + NL
#--> [ "tunis", "regueb" ]
# Executed in 0.24 second(s)

? @@SP( o1.DuplicatedItemsZ() ) + NL
# [
#	[ "tunis",  [ 2, 3, 5, 6, 8, 9 ] ],
#	[ "regueb", [ 12 ] ]
# ]
# Executed in 0.37 second(s)

? @@( o1.FindDuplicatedItems() ) + NL
#--> [ 2, 3, 5, 6, 8, 9, 12 ]
# Executed in 0.41 second(s)

//? o1.ContainsDuplicatedItem("tunis")
//? o1.ContainsDuplicationsOf("tunis")
#--> TRUE
# Executed in 0.10 second(s)

? @@( o1.FindDuplicationsOf("tunis") ) + NL
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

	//? @@( o1.FindDuplicatedItem("tunis") )
	#--> [ 1, 2, 3, 5, 6, 8, 9 ]
	# Executed in 0.12 second(s)

pf()
# Executed in 0.01 second(s).
