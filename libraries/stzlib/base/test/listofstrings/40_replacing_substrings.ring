# Narrative
# --------
# REPLACING SUBSTRINGS
#
# Extracted from stzlistofstringstest.ring, block #40.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

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
