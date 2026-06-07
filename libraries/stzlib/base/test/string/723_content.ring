# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #723.

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
