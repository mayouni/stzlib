# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #7.

load "../../stzBase.ring"


Rx( pat(:numbersAfterEquals) ) {
	? Pattern()
	#--> =\s*-?\d+(?:\.\d+)?\b

	Match("age= 34 salary=64000")
	? @@( Matches() )
	#--> [ "= 34", "=64000" ] correct!
}

pf()
