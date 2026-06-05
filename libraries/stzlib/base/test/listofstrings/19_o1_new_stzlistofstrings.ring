# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #19.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"      ........  ",
	"   ........ ",
	"       ........       ",
	"........  "
])

? @@( o1.StringsTrimmed() )
#--> [
# 	"........",
# 	"........",
# 	"........",
# 	"........"
# ]

pf()
