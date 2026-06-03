# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #460.
#ERR Error (R14) : Calling Method without definition: theseitemsz

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "e", "a", "c", "v", "e" ])

? o1.FindMany([ "a", "e" ])
#--> [ 1, 3, 4, 7 ]

? @@NL( o1.TheseItemsZ([ "a", "e" ]) )
#--> [
#	[ "a", [ 1, 4 ] ],
#	[ "e", [ 3, 7 ] ]
# ]

pf()
# Executed in almost 0 second(s).
