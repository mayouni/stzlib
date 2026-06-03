# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #62.
#ERR Error (R14) : Calling Method without definition: isdecimalnumberinstring

load "../../stzBase.ring"

pr()

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
