# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #31.

load "../../stzBase.ring"


o1 = new stzTable([
	[ "I", 1 ],
	[ AHeart(), 2 ],
	[ "Ring", 3 ],
	[ "Language", 4 ]
])

o1.ShowXT([ :UnderlineHeader = FALSE ])
#-->
# I   ♥   RING   LANGUAGE
# 1   2      3          4

pf()
# Executed in 0.08 second(s)
