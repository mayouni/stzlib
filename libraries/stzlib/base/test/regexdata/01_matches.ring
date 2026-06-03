# Narrative
# --------
# pr()
#
# Extracted from stzregexdatatest.ring, block #1.

load "../../stzBase.ring"

pr()

Rx( pat(:numbersInQuotes) ) {

//	? Pattern()
	#--> '-?\d+(?:\.\d+)?'|"-?\d+(?:\.\d+)?\"|-?\d+(?:\.\d+)?|[‘’]-?\d+(?:\.\d+)?[‘’]|[“”]-?\d+(?:\.\d+)?[“”]

	Match("'150' and ‘90’ are quoted")
	? Matches()
	#--> [ '150', ‘90’ ] correct!
}

pf()
