# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #539.

load "../../stzBase.ring"

pr()

? StzListQ([ "ض", "c", "س", "a", "ط", "b" ]).
	ItemsWF( func x { return StzCharQ(x).IsArabic() } )

#o--> [ "ض", "س", "ط" ]

pf()
# Executed in 0.13 second(s).
