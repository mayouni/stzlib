# Narrative
# --------
# ReplaceManyByManyXT: palette cycled over five occurrences of one needle.
#
# All five items are "A"; needle ["A"] with palette [ "#1","#2" ] cycles
# #1,#2,#1,#2,#1 across the five matches -> [ "#1","#2","#1","#2","#1" ].
# The clearest demonstration that XT keys on occurrence count, not on the
# (single) distinct needle.
#
# Extracted from stzlisttest.ring, block #83.

load "../../stzBase.ring"

pr()

StzListQ([ "A", "A", "A", "A", "A" ]) {
	ReplaceManyByManyXT(["A"], [ "#1", "#2" ])
	? Content()

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

pf()
