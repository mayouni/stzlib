# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #458.

load "../../stzBase.ring"

pr()

? Q("123.98").IsNumberInString()
#--> TRUE

? IsNumberInString("123.98")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21
