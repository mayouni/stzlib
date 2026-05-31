# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #500.

load "../../../stzBase.ring"


? @@NL( StzListQ([ 1, 2, 3 ]).RepeatNTimes(3) )
#--> [
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ]
# ]

pf()
# Executed in 0.02 second(s).
