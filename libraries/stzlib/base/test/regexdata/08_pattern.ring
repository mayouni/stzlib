# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #8.

load "../../stzBase.ring"

pr()

Rx( pat(:numbersInCSV) ) {
	? Pattern()
	#--> (?<=,|;|\s|^)-?\d+(?:\.\d+)?(?=,|;|\s|$)

	Match("34, 64000, 2.5, -10")
	? @@(Matches())
	#--> [ '34', '64000', '2.5', '-10' ] correct
}

Rx( pat(:numbersInCSV) ) {

	Match("34; 64000; 2.5; -10")
	? @@(Matches())
	#--> [ '34', '64000', '2.5', '-10' ] correct
}

pf()
