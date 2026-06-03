# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #306.

load "../../stzBase.ring"

pr()

o1 = new stzString("IbelieveinRingfutureandengageforit!")
o1.SpacifyTheseSubStrings([
	"believe", "in", "Ring", "future", "and", "engage", "for"
])

? o1.Content()
#--> I believe in Ring future and engage for it!

pf()
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.13 second(s) in Ring 1.19
