# Narrative
# --------
# pr()
#
# Extracted from stzList2DTest.ring, block #2.

load "../../../stzBase.ring"


o1 = new stzList2D([
	[ "A", "B" ],
	[  10,  20,  30 ]
])

#--> ERROR: Can't create the stz2DList object! All the lists must have same size.
