# Narrative
# --------
# TrimChar: strip a NAMED character from BOTH ends in one call.
#
# Where Trim (block #984) removes whitespace, TrimChar removes the leading
# AND trailing runs of the given char -- here the three hearts on each side
# of "123" -- in a single pass, codepoint-correctly. (Equivalent to
# RemoveAnyCharFromLeft + RemoveAnyCharFromRight, block #983.)
#
# The old "#ERR Line 98 Bad parameters" header was stale; the test runs
# clean against the current engine (verified to STOPPED!).
#
# Repositioned from test/list (stzlisttest.ring, block #68): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

o1 = new stzString("♥♥♥123♥♥♥")
o1.TrimChar("♥")
? o1.Content()
#--> "123"

pf()
# Executed in 0.03 second(s)
