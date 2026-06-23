# Narrative
# --------
# Removes the Nth occurrence of a value, counting forward from a chosen start.
#
# RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3) scans the list from
# position 3 onward, enumerates the matches of "A" it meets (here at positions
# 4, 6 and 8), and deletes the 2nd of those -- the "A" at position 6. The
# named-argument form (:Of / :StartingAt) reads like prose and makes the intent
# explicit: not "the 2nd A overall" but "the 2nd A seen after where I am now".
# This is the directional sibling of position-blind removal: the cursor matters.
#
# Extracted from stzlisttest.ring, block #447.

load "../../stzBase.ring"

pr()

StzListQ([ "A", "-", "-", "A", "-", "A", "-", "A" ]) {
	RemoveNextNthOccurrence(2, :Of = "A", :StartingAt = 3)
	? Content()
	#--> [ "A", "-", "-", "A", "-", "-", "A" ]
}

pf()
# Executed in almost 0 second(s).
