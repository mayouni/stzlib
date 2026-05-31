# Narrative
# --------
# pr()
#
# Extracted from stzList2DTest.ring, block #3.

load "../../../stzBase.ring"


? @@NL( Transpose([
	[ "A", "B", "C" ],
	[  10,  20,  30 ]
]) )
#-->
'
[
	[ "A", 10 ],
	[ "B", 20 ],
	[ "C", 30 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.22
