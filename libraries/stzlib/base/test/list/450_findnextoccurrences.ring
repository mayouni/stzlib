# Narrative
# --------
# Directional occurrence search: locating a value before or after a cursor.
#
# Softanza lets you scan from an arbitrary anchor instead of from the
# ends of the list. FindNextOccurrences(:Of, :StartingAt) walks forward
# from the start position and returns the positions of every later match,
# while FindPreviousOccurrences(:Of, :StartingAt) walks backward and
# returns the earlier matches in ascending order. Here the list has "A"
# at positions 1, 3, 5, 7: starting at 3 the next occurrences are 5 and 7;
# starting at 5 the previous occurrences are 1 and 3. The named-parameter
# form (:Of = ..., :StartingAt = ...) keeps the intent self-documenting.
#
# Extracted from stzlisttest.ring, block #450.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {

	? FindNextOccurrences(:Of = "A", :StartingAt = 3) #--> [ 5, 7 ]

	? FindPreviousOccurrences(:Of = "A", :StartingAt = 5) #--> [ 1, 3 ]

}

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
