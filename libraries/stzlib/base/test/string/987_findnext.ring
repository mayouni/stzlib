# Narrative
# --------
# stzString.FindNext(): resume a substring search from a given cursor.
#
# FindNext(sub, :startingAt = n) scans for the next occurrence of sub at or
# after position n. The string "123456789" has its only "1" at position 1;
# starting the scan at position 10 is already past the end, so there is
# nothing left to match and the method returns 0 -- the Softanza "not found"
# sentinel. This is the idiom for stepping a cursor through repeated matches
# and detecting when none remain.
#
# Repositioned from test/list (stzlisttest.ring, block #249): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789")
? o1.FindNext("1", :startingAt = 10)
#--> 0

pf()
