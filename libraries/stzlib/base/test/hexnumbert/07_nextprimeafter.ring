# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #7.

load "../../stzBase.ring"

pr()

? NextPrimeAfter(12)
#--> 13

? NextNthPrime(29, :After = 12)
#--> 139

? PreviousPrimeBefore(140)
#--> 139

? PreviousNthPrime(29, :Before = 140)
#--> 13

pf()
# Executed in almost 0 second(s) in Ring 1.21
