# Narrative
# --------
# Membership testing on a mixed list with Contains() and its negation ContainsNo().
#
# Contains(item) returns TRUE when the exact item is present in the list and
# FALSE otherwise. The match is case-sensitive, so "a" is not found in a list
# holding "A" -- the two are distinct items. ContainsNo(item) is the logical
# inverse: TRUE only when the item is absent. Here the list mixes strings and
# numbers, and the checks confirm that "A" and "C" are present while "a" and
# "X" are not.
#
# Extracted from stzlisttest.ring, block #396.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])

? o1.Contains("a")
#--> FALSE

? o1.Contains("A")
#--> TRUE

? o1.ContainsNo("C")
#--> FALSE

? o1.ContainsNo("X")
#--> TRUE

pf()
# Executed in 0.02 second(s).
