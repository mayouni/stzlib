# Narrative
# --------
# Case-sensitivity-aware membership and search across a mixed list.
#
# o1 holds strings of varying case ("ab", "abA", "abAb") alongside
# repeated ranges (1:3). ContainsCS asks "is 'ab' present?" with the
# case flag TRUE, and gets a hit (printed as 1, Ring's truth value).
# FindFirstCS/FindLastCS take a flag too: with FALSE (case-insensitive)
# "AB" first matches at position 2 and "ABA" last matches at position 4.
# FindFirst/FindLast also accept a range item: 1:3 first appears at
# position 3 and last at position 6, showing items can be ranges, not
# just scalars. The CS suffix is the Softanza dial for case sensitivity.
#
# Extracted from stzlisttest.ring, block #265.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "ab", 1:3, "abA", "abAb", 1:3 ])

? o1.ContainsCS("ab", TRUE)
#--> TRUE

? o1.FindFirstCS("AB", FALSE)
#--> 2

? o1.FindLastCS("ABA", FALSE)
#--> 4

? o1.FindFirst(1:3)
#--> 3

? o1.FindLast(1:3)
#--> 6

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.17
