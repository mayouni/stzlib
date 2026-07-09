# Narrative
# --------
# Mapping each distinct item to the list of positions where it occurs.
#
# ItemsZ() (alias ItemsAndTheirPositions()) is the Z-suffixed, "zipped"
# inventory view of a list: it walks the list once and, for every unique
# value, collects all 1-based positions at which that value appears. The
# result is a list of [ value, [ positions... ] ] pairs in first-seen
# order, so duplicates like "Ab" (at 1, 3, 6) and "Cf" (at 4, 7) are
# folded into a single entry carrying their full position set. This is the
# building block behind frequency/occurrence queries without losing the
# where-it-happened detail that a plain count would discard.
#
# Extracted from stzlisttest.ring, block #245.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Ab", "Im", "Ab", "Cf", "Fd", "Ab", "Cf" ])
? @@( o1.ItemsZ() ) # Or ItemsAndTheirPositions()
#--> [
#	[ "Ab", [ 1, 3, 6 ] ],
#	[ "Im", [ 2 ] ],
#	[ "Cf", [ 4, 7 ] ],
#	[ "Fd", [ 5 ] ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
