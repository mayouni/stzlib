# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #723.
#ERR Error (R3) : Calling Function without definition: replacecharswxt

load "../../stzBase.ring"

pr()

StzStringQ("1a2b3c") {

	ReplaceCharsWXT(
		:Where = '{ Q(@char).isLowercase() }',
		:With  = "*"
	)

	? Content()
	#--> 1*2*3*
}

pf()
# Executed in 0.16 second(s).
