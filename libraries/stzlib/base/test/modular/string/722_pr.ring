# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #722.

load "../../../stzBase.ring"


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
