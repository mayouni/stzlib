# Narrative
# --------
# Using Diff()
#
# Extracted from stzmatrixtest.ring, block #23.

load "../../../stzBase.ring"


pr()

# Let's say we have a time series representing daily temperatures:

o1 = new stzMatrix([
	[ 20, 22, 21, 23, 25 ], # day 1
	[ 18, 20, 17, 25, 28 ], # day 2
	[ 19, 17, 14, 23, 34 ]  # day 3
])

# Calculating temparture differences

? @@NL( o1.Diff() )
#--> [
#	[  2, -1, 2,  2 ],
#	[  2, -3, 8,  3 ],
#	[ -2, -3, 9, 11 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
