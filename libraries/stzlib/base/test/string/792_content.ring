# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #792.

load "../../stzBase.ring"

pr()

StzStringQ( "a + b - c / d = 0" ) {
	ReplaceMany( [ "+", "-", "/" ], "*" )
	? Content()
}
#--> a * b * c * d = 0

pf()
# Executed in 0.01 second(s).
