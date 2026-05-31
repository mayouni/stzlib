# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #539.

load "../../../stzBase.ring"


? StzListQ([ "ض", "c", "س", "a", "ط", "b" ]).
	ItemsWXT('StzCharQ(@item).IsArabic()')

#o--> [ "ض", "س", "ط" ]

pf()
# Executed in 0.13 second(s).
