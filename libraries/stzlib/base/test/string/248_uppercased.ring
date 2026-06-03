# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #248.

load "../../stzBase.ring"

pr()

? Q("i believe in ring future and engage for it!").Uppercased()
#--> I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!

? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").IsUppercase()
#--> TRUE

StopProfiler()

pf()
# Executed in 0.05 second(s) in Ring 1.21
