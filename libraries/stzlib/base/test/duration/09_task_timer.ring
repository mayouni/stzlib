# Narrative
# --------
# Task Timer
#
# Extracted from stzdurationtest.ring, block #9.

load "../../stzBase.ring"


pr()

nStartTime = clock()

# Simulate work
for i = 1 to 1000000
	# Work happening...
next

nEndTime = clock()
o1 = DurationQ(nEndTime - nStartTime)

? o1.ToHuman()
#--> 14 seconds

? o1.TotalSeconds()
#--> 14

pf()
# Executed in 0.01 second(s) in Ring 1.24
