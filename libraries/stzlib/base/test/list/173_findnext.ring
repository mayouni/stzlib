# Narrative
# --------
# FindNext() returns the position of the next occurrence of a value,
# scanning forward from a chosen start point.
#
# Here the list holds two "*" markers, at positions 4 and 7. Calling
# FindNext("*", :StartingAt = 4) tells Softanza to begin the search
# from position 4 onward and report the FOLLOWING match, so it skips
# the marker sitting at the start point and returns 7. This is the
# idiom for stepping through repeated markers one hop at a time: feed
# the last hit back as the StartingAt to walk to the next one.
#
# Extracted from stzlisttest.ring, block #173.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindNext("*", :StartingAt = 4)
#--> 7

pf()
# Executed in 0.05 second(s)
