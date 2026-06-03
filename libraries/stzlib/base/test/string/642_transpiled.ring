# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #642.

load "../../stzBase.ring"

pr()

? StzCCodeQ('@char = "I"').Transpiled()
#--> This[@i]  = "I"

pf()
# Executed in 0.18 second(s)
