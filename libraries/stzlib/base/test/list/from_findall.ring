# Narrative
# --------
# FindAll positions of a value, and the duplicate-finding API, on a stzList.
#
# FindAll is case-sensitive by default; FindAllCS takes a case dial (the
# :cs = TRUE|FALSE named param), so "tunis" can also match "TuNIS"/"Tunis"/...
# The duplicate methods then report the repeated values, their positions, and
# the keyed value->positions view.
#
# Extracted from stzlistofliststest.ring, block #90.

load "../../stzBase.ring"

pr()

# --- FindAll / FindAllCS ----------------------------------------------------

o1 = new stzList([
	"TuNIS", "Tunis", "TUNIS", "TUNIS",
	"gatufsa", "tunis", "tunis",
	"gabes", "Tunis", "Tunis",
	"regueb", "tuta", "regueb", "tunis" ])

? @@( o1.FindAll("tunis") )
#--> [ 6, 7, 14 ]

? @@( o1.FindAllCS("tunis", TRUE) )
#--> [ 6, 7, 14 ]

? @@( o1.FindAllCS("tunis", :cs = FALSE) )
#--> [ 1, 2, 3, 4, 6, 7, 9, 10, 14 ]

# --- duplicated values ------------------------------------------------------

o1 = new stzList([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? o1.ContainsDuplicatedItems()
#--> TRUE

? @@( o1.DuplicatedItems() )
#--> [ "tunis", "regueb" ]

? @@( o1.DuplicatedItemsZ() )
#--> [ [ "tunis", [ 2, 3, 5, 6, 8, 9 ] ], [ "regueb", [ 12 ] ] ]

# all duplicate (2nd+) positions across the list
? @@( o1.FindDuplicatedItems() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]

# the duplicate positions of one specific value
? @@( o1.FindDuplicationsOf("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
