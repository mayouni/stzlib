# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #9.

load "../../../stzBase.ring"


Rx( pat(:numbersInBrackets) ) {
	? Pattern() + NL
	#--> \[\s*-?\d+(?:\.\d+)?\s*\]

	Match("[34] and [64000]")
	? @@( Matches() )
	#--> [ "[34]", "[64000]" ] correct
}

pf()
