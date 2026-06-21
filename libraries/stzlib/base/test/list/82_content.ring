# Narrative
# --------
# ReplaceManyByManyXT: several distinct needles, palette cycled over their
# combined matches.
#
# Needles [ "*","_","/" ] match once each (positions 3,4,5); the palette
# [ "#1","#2" ] cycles #1,#2,#1 across those three matched positions, giving
# [ "#1","#2","#1","#2","#1" ]. Same occurrence-order cycling as #81, just
# spread over different needles -- the matched POSITIONS are what drive it.
#
# Extracted from stzlisttest.ring, block #82.

load "../../stzBase.ring"

pr()

StzListQ([ "#1", "#2", "*", "_", "/" ]) {
	ReplaceManyByManyXT(["*", "_", "/"], [ "#1", "#2" ])
	? @@( Content() )

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

pf()
# Executed in 0.07 second(s)
