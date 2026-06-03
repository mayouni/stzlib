# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #11.

load "../../stzBase.ring"


cStr = " line1 line1 line1 
line2 line2 line2
line3 line3 line3"

? stzsplit(cStr, NL)
#--> [
#	" line1 line1 line1",
#	"line2 line2 line2",
#	"line3 line3 line3"
# ]

pf()
# Executed in almost 0 second(s).
