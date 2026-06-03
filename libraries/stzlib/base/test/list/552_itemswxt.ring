# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #552.
#ERR Error (R14) : Calling Method without definition: itemswxt

load "../../stzBase.ring"

pr()

o1 = new stzList( [ "c", "c++", "C#", "RING", "Python", "RUBY" ] )
? o1.ItemsWXT('{ Q(@item).IsLowercased() }')
#--> [ "c", "c++" ]

? o1.FirstItemWXT('{ Q(@item).IsLowercased() }') + NL
#--> "c"

? o1.NthItemWXT(2, '{ Q(@item).IsLowercased() }') + NL
#--> "c++"

? o1.LastItemWXT('{ Q(@item).IsLowercased() }')
#--> "c++"

pf()
# Executed in 0.55 second(s).
