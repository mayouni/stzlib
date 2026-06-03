# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #45.

load "../../stzBase.ring"


o1 = new stzMatrix([
	[ 14, 20, 16 ],
	[ 14, 20, 16 ],
	[ 17, 23, 19 ],
])

? @@( o1.Section([1, 1], [2, 2]) )
#--> [ 14, 14, 20, 20 ]

? @@NL( o1.FindElementsInSection([1, 1], [2, 2]) )
#--> [
#	[ 1, 1 ],
#	[ 2, 1 ],
#	[ 1, 2 ],
#	[ 2, 2 ]
# ]

? @@NL( o1.ElementsInSectionZ([1, 1], [2, 2]) )
#--> [
#	[
#		14,
#		[ 1, 1 ]
#	],
#	[
#		14,
#		[ 2, 1 ]
#	],
#	[
#		20,
#		[ 1, 2 ]
#	],
#	[
#		20,
#		[ 2, 2 ]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
