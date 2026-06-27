# Narrative
# --------
# RepeatNTimes(n): repeat a list as n NESTED copies.
#
# Repeating a list yields a list CONTAINING that list n times:
# [1,2,3] -> [ [1,2,3], [1,2,3], [1,2,3] ]. Repeat / Repeated / RepeatNTimes /
# RepeatedNTimes all do this now. (Flat concatenation is the (*) operator:
# o1 * 3 -> [1,2,3,1,2,3,1,2,3].)
#
# Extracted from stzlisttest.ring, block #500.

load "../../stzBase.ring"

pr()

? @@NL( StzListQ([ 1, 2, 3 ]).RepeatNTimes(3) )
#--> [
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ]
# ]

pf()
# Executed in 0.02 second(s).
