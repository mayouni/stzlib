# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #51.

load "../../stzBase.ring"

pr()

? ComputableForm(4) # or use the abbreviated form @@(4)
#--> 4

? ComputableForm("Ring")
#--> "Ring"

? ComputableForm([ 1, 2, "a" ])
#--> [
#	1,
#	2,
#	"a"
#]

? ComputableForm([ 1, 2, "a" ]) # or use the abbreviated form @@(...)
#--> [ 1, 2, "a" ]

pf()
# Executed in almost 0 second(s).
