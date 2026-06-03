# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #722.
#ERR Error (R3) : Calling Function without definition: replacecharswxt

load "../../stzBase.ring"

pr()

StzStringQ( "Text processing with Ring" ) {

	ReplaceCharsWXT(
		:Where = '{ @char = "i" }',
		:With = "*"	
	)

	? Content()
}

#--> "Text process*ng w*th R*ng"

pf()
# Executed in 0.20 second(s).
