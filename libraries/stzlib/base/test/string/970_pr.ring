# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #970.

load "../../stzBase.ring"


o1 = new stzString("^---^---^---^---")

o1.ReplaceSectionsByMany(
	[ [ 1, 1 ], [ 5, 5 ], [ 9, 9 ], [ 13, 14 ] ],
	[ "1", "5", "9", "13" ]
)

? o1.Content()
#--> 1---5---9---13--

pf()
# Executed in 0.01 second(s) in Ring 1.21
