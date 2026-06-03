# Narrative
# --------
# StartProfiler()
#
# Extracted from stzccodetest.ring, block #7.

load "../../stzBase.ring"

pr()

o1 = new stzCCode('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
? o1.ExecutableSection()
#--> [4, -3]

StopProfiler()

pf()
# Executed in 0.05 second(s) in Ring 1.23
# Executed in 0.07 second(s) in Ring 1.22
# Executed in 0.09 second(s) in Ring 1.21
# Executed in 0.22 second(s) in ring 1.17
