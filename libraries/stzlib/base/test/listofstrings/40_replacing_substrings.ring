# Narrative
# --------
# REPLACING SUBSTRINGS
#
# Extracted from stzlistofstringstest.ring, block #40.
#ERR Error (R14) : Calling Method without definition: replacesubstringatposition

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"___ ring ___ ring",
	"ring ___ ring ___ ring",
	"___ ring"
])

o1.ReplaceSubStringAtPosition( [2, 10], "ring", "♥♥♥" )

? @@(o1.Content() )
#--> [ "___ ring ___ ring", "ring ___ ♥♥♥ ___ ring", "___ ring" ]

pf()
