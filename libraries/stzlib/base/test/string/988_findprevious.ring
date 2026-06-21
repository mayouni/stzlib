# Narrative
# --------
# stzString backward search: FindPrevious and FindNthPrevious.
#
# FindPrevious(sub, :StartingAt = n) scans leftward from position n and returns
# the nearest earlier match. In "12♥4♥67" the hearts sit at positions 3 and 5;
# starting at 5, the previous heart is at 3. FindNthPrevious(2, sub,
# :StartingAt = 6) walks back two matches from position 6 -- first the heart at
# 5, then the heart at 3 -- so it returns 3. Both ride the codepoint-aware
# backward scan (the multibyte heart is matched whole).
#
# Repositioned from test/list (stzlisttest.ring, block #275): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

o1 = new stzString("12♥4♥67")

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 6)
#--> 3

pf()
# Executed in 0.01 second(s)
