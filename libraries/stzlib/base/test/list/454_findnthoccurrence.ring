# Narrative
# --------
# Locating and rewriting the Nth occurrence of a repeated value.
#
# FindNthOccurrence(n, :Of = value) returns the absolute position of the
# n-th time a value appears, scanning left to right. Here "A" occurs at
# positions 1, 4 and 7, so the 3rd occurrence is at position 7.
# ReplaceNthOccurrence(n, :Of = value, :With = newValue) is the surgical
# counterpart: it edits only that single occurrence and leaves the other
# matches untouched, so the trailing "A" becomes "#" while the earlier
# A's stay in place. The named :Of / :With arguments make the intent
# read like a sentence.
#
# Extracted from stzlisttest.ring, block #454.

load "../../stzBase.ring"

pr()

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {

	? FindNthOccurrence(3, :Of = "A") + NL
	#--> 7

	ReplaceNthOccurrence(3, :Of = "A", :With = "#")
	? Content()
	#--> [ "A", "B", "C", "A", "D", "B", "#" ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.21
