# Narrative
# --------
# pr()
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
