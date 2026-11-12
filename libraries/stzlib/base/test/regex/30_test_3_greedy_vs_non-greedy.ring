# Narrative
# --------
# Test 3: Greedy vs Non-greedy
#
# Extracted from stzRegexTest.ring, block #30.
#
# CORRECTED 2026-11-12, on two counts.
#
# (1) It could not run at all. `new stzRegex("")` raises "You must provide a
#     non-empty pattern string" -- the constructor was tightened at some point and
#     this block still built an empty object and called SetPattern afterwards. So
#     the only test of :NonGreedy in the tree had no live coverage whatsoever.
#
# (2) Its discriminator could not have worked even once it ran. Both blocks used
#     :MatchEntireContent, which anchors BOTH ends, and laziness changes only the
#     ORDER in which a match is attempted, never which matches exist. With both
#     ends pinned, greedy and lazy reach the same match and both answer TRUE --
#     which is exactly what the two #--> TRUE lines recorded.
#
# The match type is unanchored now, and the SPANS are asserted, because the extent
# of the match is the whole question and a boolean cannot carry it.

load "../../stzBase.ring"


pr()

txt = "<p>First</p><p>Second</p>"

? len(txt)
#--> 25

# Greedy (default): the match runs to the LAST close.

o1 = new stzRegex("<p>.*</p>")

? o1.MatchXT(txt, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll ])
#--> 1

? o1.CapturedLength()
#--> 25

# Non-greedy: the match stops at the FIRST close.

o2 = new stzRegex("<p>.*</p>")

? o2.MatchXT(txt, 1, :MatchFirstOccurrenceIfNotGoPartial, [ :DotMatchesAll, :NonGreedy ])
#--> 1

? o2.CapturedLength()
#--> 12

pf()
