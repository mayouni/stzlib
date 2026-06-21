# Narrative
# --------
# Removes duplicate items from a list while preserving first-seen order.
#
# U() is the terse global alias for Unique() / WithoutDuplicates(): it
# walks the list once and keeps only the first occurrence of each value,
# so the result reflects the order items first appeared rather than a
# sorted order. It is type-agnostic -- strings (including the Unicode
# heart), numbers, and any mix coexist, and equality is by value, so the
# two "♥" entries and the pair of 2s collapse to a single copy each.
#
# Extracted from stzlisttest.ring, block #86.

load "../../stzBase.ring"

pr()

? U([ "♥", 1, 2, 2, "♥", "♥", 3 ]) # Or Unique() or WithoutDuplicates()
#--> [ "♥", 1, 2, 3 ]

pf()
# Executed in 0.01 second(s)
