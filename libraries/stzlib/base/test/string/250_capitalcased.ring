# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #250.

load "../../stzBase.ring"

pr()

? Q("i believe in ring future and engage for it!").Capitalcased()
#--> I Believe In Ring Future And Engage For It!

? Q("I Believe In Ring Future And Engage For It!").IsCapitalcase()
#--> TRUE

StopProfiler()

pf()
# Executed in 0.07 second(s) in Ring 1.21
