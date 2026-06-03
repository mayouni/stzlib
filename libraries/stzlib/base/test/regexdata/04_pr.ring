# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #4.

load "../../stzBase.ring"


Rx( pat(:numbersAsValuesInPairs) ) {
	? Pattern()
	#--> ,\s*(?:"([+-]?\d+(?:\.\d+)?)"|([+-]?\d+(?:\.\d+)?))

	Match('[ [ "name", "John" ], [ "age", 34 ], [ "salary", "64000" ] ]')
	? @@( Matches() )
	#--> [ ", 34", ', "64000"' ]

}

pf()
