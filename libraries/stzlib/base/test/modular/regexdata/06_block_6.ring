# Narrative
# --------
# */
#
# Extracted from stzregexdatatest.ring, block #6.

load "../../../stzBase.ring"

pr()

Rx( pat(:numbersInParentheses) ) {
	? Pattern()
	#--> \(\s*-?\d+(?:\.\d+)?\s*\)

	Match("(34) and (64000)")
	? @@( Matches() )
	#--> [ (34), (64000) ] corrrect!
}

pf()
