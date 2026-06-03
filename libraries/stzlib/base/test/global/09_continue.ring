# Narrative
# --------
# Continue
#
# Extracted from stzGlobalTest.ring, block #9.

load "../../stzBase.ring"


pr()

# What if we disable the params cheks and see what gain we could obtain:

CheckParamOff()
_bParamCheck = false

aList1 = 1 : 1_500_000
aList2 = 4 : 1_500_003

? EuclideanDistance(aList1, aList2)
#--> 3674.23

# A lot faster!

pf()
# Executed in 0.89 second(s) in Ring 1.22
# Executed in 2.05 second(s) in Ring 1.22
