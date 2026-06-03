# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #55.

load "../../stzBase.ring"


o1 = new stzTable([
	[ "COL1", [ "A", "B", "C" ] ],
	[ "COL2", [ "a", "b", "c" ] ],
	[ "COL3", [ "1", "2", "3" ] ]
])

o1.Show()
#-->
#   COL1   COL2   COL3
#   ----- ------ -----
#      A      a      1
#      B      b      2
#      C      c      3

pf()
# Executed in 0.09 second(s) in Ring 1.20
# Executed in 0.54 second(s) in Ring 1.17
