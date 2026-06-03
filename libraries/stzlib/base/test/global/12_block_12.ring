# Narrative
# --------
# #perf #narration
#
# Extracted from stzGlobalTest.ring, block #12.

load "../../stzBase.ring"


pr()

# The Ring for loop is quick! Hence it loops 5 million
#  times in a fraction of second:

for i = 1 to 5_000_000
	// Do nothing
next

pf()
# Executed in 0.07 second(s) in Ring 1.24
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 0.12 second(s) in Ring 1.19
# Executed in 0.44 second(s) in Ring 1.17
