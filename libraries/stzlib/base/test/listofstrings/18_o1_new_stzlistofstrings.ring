# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #18.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	".;.;.",
	"-;-;-",
	"*;*;*"
])
? @@( o1.Splitted(:Using = ";") )
#--> [
#	[ ".", ".", "." ],
#	[ "-", "-", "-" ],
#	[ "*", "*", "*" ]
# ]

pf()
