# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #83.

load "../../stzBase.ring"


StzListQ([ "A", "A", "A", "A", "A" ]) {
	ReplaceManyByManyXT(["A"], [ "#1", "#2" ])
	? Content()

}
#--> [ "#1", "#2", "#1", "#2", "#1" ]

pf()
