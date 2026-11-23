# Narrative
# --------
#
# Extracted from stzList2DTest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = new stzList2D([
	[ "A", "B", "C" ],
	[  10,  20,  30 ]
])

o1.Transpose()
# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
? @@NL( o1.Content() )
#--> [
#--> [ "A", 10 ],
#--> [ "B", 20 ],
#--> [ "C", 30 ]
#--> ]
'
[
	[ "A", 10 ],
	[ "B", 20 ],
	[ "C", 30 ]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22
