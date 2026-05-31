# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #82.

load "../../../stzBase.ring"


StzListQ([ "#1", "#2", "*", "_", "/" ]) {
	ReplaceManyByManyXT(["*", "_", "/"], [ "#1", "#2" ])
	? @@( Content() )

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

pf()
# Executed in 0.07 second(s)
