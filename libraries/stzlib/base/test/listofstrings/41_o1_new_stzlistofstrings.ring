# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #41.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

o1.ReplaceNthOccurrenceOfSubString(4, "ring", "♥♥♥")

? @@(o1.Content() )
#--> [ "___ ring ___ ring", "ring ___ ♥♥♥ ___ ring", "___ ring" ]

pf()
