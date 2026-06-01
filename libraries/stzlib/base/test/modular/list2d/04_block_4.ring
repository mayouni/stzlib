# Narrative
# --------
#
# Extracted from stzList2DTest.ring, block #4.

load "../../../stzBase.ring"

pr()

o1 = new stzList2D([
	[ "A", "B", "C" ],
	[  10,  20,  30 ]
])

o1.Transpose()
? @@NL( o1.Content() )
#-->
'
[
	[ "A", 10 ],
	[ "B", 20 ],
	[ "C", 30 ]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22
