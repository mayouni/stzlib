# Narrative
# --------
# StartProfiler()
#
# Extracted from stzccodetest.ring, block #8.

load "../../stzBase.ring"

pr()

o1 = new stzString('This[@i] = This[@i + 1] + @i - 2')
? o1.NumbersAfter("@i")
#--> [ "+1", "-2" ]

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.16 second(s) in ring 1.17
