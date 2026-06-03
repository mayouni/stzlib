# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #5.

load "../../stzBase.ring"

pr()

Rx( pat(:numbersAsValuesInJSON) ) {
	? Pattern()
	#--> :\s*"?([+-]?\d+(?:\.\d+)?)"?

	Match('{ "age": 34, "salary": "64000" }')

	? @@( Matches() )
	#--> [ ": 34", ': "64000"' ]
}

pf()
