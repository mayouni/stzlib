# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #468.
#ERR Error (R14) : Calling Method without definition: theseitemsz

load "../../stzBase.ring"

pr()

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])
? o1.FindMany([ :one, :two, :four ])
#--> [ 1, 2, 3, 5, 6 ]

? o1.TheseItemsZ([ :one, :two, :four ])
#--> [ :one = [ 1, 3, 5 ], :two = [ 2 ], :four = [ 6 ] ]

pf()
# Executed in almost 0 second(s).
