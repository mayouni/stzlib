# Narrative
# --------
# Directional substring search in a stzString, anchored by :StartingAt.
#
# Over "12•4•67" the bullets sit at positions 3 and 5. FindNext finds the first
# separator strictly after the anchor, FindPrevious the first one strictly
# before it. The Nth variants ask for the Nth hit in that direction: starting
# at 3 there is only ONE later bullet (at 5), so the 2nd-next request returns 0;
# symmetrically, starting at 5 there is only one earlier bullet (at 3), so the
# 2nd-previous request also returns 0. Softanza reports 0 for "no such
# occurrence" rather than raising. (The stale recorded 5/3 on the Nth lines
# were copies of the non-Nth results.)
#
# Repositioned from test/list (stzlisttest.ring, block #301): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

#                     3 5
o1 = new stzString("12•4•67")

? o1.FindNext("•", :StartingAt = 3)
#--> 5

? o1.FindNextNth(2, "•", :StartingAt = 3)
#--> 0

? o1.FindPrevious("•", :StartingAt = 5)
#--> 3

? o1.FindPreviousNth(2, "•", :StartingAt = 5)
#--> 0

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.20
