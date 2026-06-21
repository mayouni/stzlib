# Narrative
# --------
# ReplaceManyByManyXT: cycling across multiple OCCURRENCES of a single needle.
#
# Only one needle ["*"], but it occurs three times (positions 3,4,5); the
# palette [ "#1","#2" ] cycles #1,#2,#1 over those three matches -> the list
# becomes [ "#1","#2","#1","#2","#1" ]. This is the key behaviour the XT form
# guarantees: occurrences of the same value still advance the palette (the
# non-XT distinct form would map every "*" to one value instead).
#
# Extracted from stzlisttest.ring, block #81.

load "../../stzBase.ring"

pr()

StzListQ([ "#1", "#2", "*", "*", "*" ]) {
	ReplaceManyByManyXT(["*"], [ "#1", "#2" ])
	? @@( Content() )

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

pf()
# Executed in 0.07 second(s)
