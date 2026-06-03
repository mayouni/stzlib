# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #11.

load "../../stzBase.ring"


Rx( pat(:numbersInList) ) {
	? Pattern() + NL
	#--> \[\s*[\w"',\s]*(?:^|,)\s*(")?(-?\d+(?:\.\d+)?)(")?(?:\s*,|\s*\])

	Match('[ "apple", 34, "banana", "64000" ]')
	? @@(Matches()) + nl
	#--> [ "34", "64000" ] correct
}

Rx( pat(:numbersInList) ) {
	? Pattern() + NL
	#--> \[\s*[\w"',\s]*(?:^|,)\s*(")?(-?\d+(?:\.\d+)?)(")?(?:\s*,|\s*\])

	Match("[ 'apple', 34, 'banana', '64000' ]")
	? @@(Matches())
	#--> [ "34", "64000" ] correct
}

pf()
