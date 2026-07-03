# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #506.
#
# NOTE (audit, 2026-07-03): left as a VISUAL demo. The block builds a
# stzTable from hardcoded QHH-style rows and Show()s it -- table
# rendering is display-only (stzTable domain) and the layout glyphs are
# not assertable. The underlying history feature itself is asserted in
# tests 466-469, 489 and 505.

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

pf()
# Executed in 0.071 second(s) in Ring 1.22
