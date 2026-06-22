# Narrative
# --------
# Locating the occurrences of an item that come AFTER a starting position.
#
# Given a list with the item "A" repeated at positions 1, 3, 5 and 7,
# FindNextOccurrencesST("A", 3) reports every position of "A" strictly
# after position 3 -- yielding [ 5, 7 ]. The ST suffix marks the
# "Starting" / "from a given position" variant of the find family.
# FindNextNthOccurrencesST([1, 2], "A", 3) selects the 1st and 2nd of
# those next occurrences (still [ 5, 7 ] here, since only two remain),
# letting you pick specific ordinals among the matches that follow a cut.
#
# Extracted from stzlisttest.ring, block #443.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A" , "B", "A", "C", "A", "D", "A" ])

? o1.FindNextOccurrencesST("A", 3)
#--> [ 5, 7 ]

? o1.FindNextNthOccurrencesST([1, 2], "A", 3)
#--> [ 5, 7 ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
