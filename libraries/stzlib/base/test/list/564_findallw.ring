# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #564.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

? o1.FindAllW('{ IsLowercase(@item) }')
#--> [ 1, 2, 5 ]
# Executed in 0.08 second(s).

? o1.FindAllWF( func x { return Q(x).IsLowercase() } )
#--> [ 1, 2, 5 ]
# Executed in 0.14 second(s).

pf()
# Executed in 0.18 second(s).
