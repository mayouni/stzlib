# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #552.

load "../../stzBase.ring"

pr()

o1 = new stzList( [ "c", "c++", "C#", "RING", "Python", "RUBY" ] )
? o1.ItemsWF( func x { return Q(x).IsLowercased() } )
#--> [ "c", "c++" ]

? o1.FirstItemWF( func x { return Q(x).IsLowercased() } ) + NL
#--> "c"

? o1.NthItemWF(2, func x { return Q(x).IsLowercased() } ) + NL
#--> "c++"

? o1.LastItemWF( func x { return Q(x).IsLowercased() } )
#--> "c++"

pf()
# Executed in 0.55 second(s).
