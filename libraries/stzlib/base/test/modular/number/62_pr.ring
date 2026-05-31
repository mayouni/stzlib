# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #62.

load "../../../stzBase.ring"


Q(14) {

	? IsDividableBy(2)
	#--> TRUE

	? IsDividableBy("2")
	#--> TRUE

	? IsDividableBy("2.00")
	#--> TRUE

	? IsDividableBy("2.001")
	#--> FALSE
}

pf()
