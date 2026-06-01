# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #247.

load "../../../stzBase.ring"


? Q("RING").StringCase()
#--> :Uppercase

? Q("ring").StringCase()
#--> :Lowercase

? Q("Ring").StringCase()
#--> :Capitalcase

? Q("Ring is AWOSOME!").StringCase()
#--> :Hybridcase

StopProfiler()
# Executed in 0.28 second(s) in Ring 1.21
