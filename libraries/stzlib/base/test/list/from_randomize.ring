# Narrative
# --------
# Shuffling a stzList in place. The result order is RANDOM, so we assert the
# deterministic invariants instead of an exact order:
#   Randomize()            - the whole list is shuffled (multiset preserved)
#   RandomizeNumbers()     - only the numbers move; the strings keep their slots
#   RandomizeSection(a, b) - only that slice moves; the rest stays put
#
# Extracted from stzrandomtest.ring, block #2.

load "../../stzBase.ring"

pr()

# Full shuffle: same items, possibly different order
aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.Randomize()
? ( len(o1.Content()) = 8 and o1.ContainsAllOfThese(aDeck) )
#--> 1
# e.g. [ "D", 4, "A", 3, "C", 2, 1, "B" ]  (varies each run)

# Only the numbers are shuffled -- the strings stay at positions 5..8
aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeNumbers()
c = o1.Content()
? ( @@([ c[5], c[6], c[7], c[8] ]) = @@([ "A", "B", "C", "D" ]) and o1.ContainsAllOfThese(aDeck) )
#--> 1

# Only positions 5..8 are shuffled -- positions 1..4 stay [ 1, 2, 3, 4 ]
aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeSection(5, 8)
c = o1.Content()
? ( @@([ c[1], c[2], c[3], c[4] ]) = @@([ 1, 2, 3, 4 ]) and o1.ContainsAllOfThese(aDeck) )
#--> 1

pf()
# Executed in almost 0 second(s) in Ring 1.27
