# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #467.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :one, :two, :one, :three, :one, :four ])

? o1.FindMany([ :one, :five ])
#--> [ 1, 2, 3, 5 ]

? @@(o1.TheseItemsZ([ :one, :five ]))
#--> [ :one = [ 1, 3, 5 ], :five = [] ]

pf()
# Executed in almost 0 second(s).
