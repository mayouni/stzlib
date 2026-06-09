# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #18.
#ERR Error (R14) : Calling Method without definition: splitted

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

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
