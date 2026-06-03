# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #18.

load "../../stzBase.ring"

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
