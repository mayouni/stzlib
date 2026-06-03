# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #506.

load "../../stzBase.ring"

pr()

decimals(3)

o1 = new stzTable([
	[ "VALUE", "TYPE", "TIME" ],
	#---------------------------#
	[ "LIFE", "stzstring", 0 ],
	[ "LIFE", "stzstring", 0.009 ],
	[ "L I F E", "stzstring", 0.009 ],
	[ [ "l", "i", "f", "e" ], "stzlist", 0.011 ],
	[ "LIFE", "stzstring", 0.026 ],
	[ "⅂IℲƎ", "stzstring", 0.071 ]
])

o1.Show()
#-->
#                  VALUE        TYPE    TIME
# ----------------------- ----------- ------
#                   LIFE   stzstring       0
#                   LIFE   stzstring   0.009
#                L I F E   stzstring   0.009
# [ "l", "i", "f", "e" ]     stzlist   0.011
#                   LIFE   stzstring   0.026
#                   ⅂IℲƎ   stzstring   0.071

pf()
# Executed in 0.071 second(s) in Ring 1.22
