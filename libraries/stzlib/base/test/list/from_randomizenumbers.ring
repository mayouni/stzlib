# Narrative
# --------
# Type-targeted shuffles on a stzList. The order is RANDOM, so we assert the
# invariants (which positions are frozen, and that the multiset is preserved):
#   RandomizeNumbers()  - only number slots are reshuffled
#   RandomizeStrings()  - only string slots are reshuffled
#   RandomizeSection()  - only the given slice is reshuffled
#
# Extracted from stzrandomtest.ring, block #10.

load "../../stzBase.ring"

pr()

# Only the numbers move; the string slots (1,2,7,8,9) stay put
aL = [ "A", "B", 30, 40, 50, 60, "A", "B", "C" ]
o1 = new stzList(aL)
o1.RandomizeNumbers()
c = o1.Content()
? ( @@([ c[1], c[2], c[7], c[8], c[9] ]) = @@([ "A", "B", "A", "B", "C" ]) and o1.ContainsAllOfThese(aL) )
#--> 1

# Only the strings move; the number slots (1..4) stay put
aL = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aL)
o1.RandomizeStrings()
c = o1.Content()
? ( @@([ c[1], c[2], c[3], c[4] ]) = @@([ 1, 2, 3, 4 ]) and o1.ContainsAllOfThese(aL) )
#--> 1

# Only positions 1..4 move; positions 5..8 stay [ "A", "B", "C", "D" ]
aL = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aL)
o1.RandomizeSection(1, 4)
c = o1.Content()
? ( @@([ c[5], c[6], c[7], c[8] ]) = @@([ "A", "B", "C", "D" ]) and o1.ContainsAllOfThese(aL) )
#--> 1

pf()
