# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #2.

load "../../../stzBase.ring"


Rx( pat(:numbersInsideString) ) {
	//? Pattern()
	#--> (?<!\w)-?\d+(?:\.\d+)?(?!\w)

	Match("I have 150 dollars and 90 cents")
	? @@( Matches() )
	#--> [ '150', '90' ] correct!
}

pf()
# Executed in 0.01 second(s) in Ring 1.22
