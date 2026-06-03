# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #10.

load "../../stzBase.ring"

pr()

Rx( pat(:numbersAfterColon) ) {
	? Pattern()
	# :\s*-?\d+(?:\.\d+)?\b

	Match("age: 34, salary: 64000")
	? @@( Matches() )
	#--> [ ": 34", ": 64000" ] correct
}

pf()
