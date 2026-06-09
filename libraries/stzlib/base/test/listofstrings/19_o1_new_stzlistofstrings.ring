# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #19.
#ERR Error (R14) : Calling Method without definition: stringstrimmed

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
