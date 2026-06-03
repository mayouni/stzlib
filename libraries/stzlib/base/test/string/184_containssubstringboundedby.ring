# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #184.

load "../../stzBase.ring"

pr()

? Q("^^♥♥♥^^").ContainsSubStringBoundedBy("♥♥♥", ["^^","^^"])
#--> TRUE

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.18
