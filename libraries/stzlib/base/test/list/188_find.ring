# Narrative
# --------
# Finding a value inside a large numeric range with the global StzFindFirst().
#
# StzFindFirst(1:299_000, 40_000) searches the contiguous integer range from 1 to
# 299000 for the value 40000 and returns its 1-based position. Because the range
# starts at 1 and increments by 1, the position of any value equals the value
# itself, so the answer is 40000. This also shows StzFindFirst() handling a range
# expression (1:299_000) as the haystack without materializing concerns, and the
# numeric-underscore literal syntax (299_000, 40_000) for readability.
#
# Extracted from stzlisttest.ring, block #188.

load "../../stzBase.ring"

pr()

? StzFindFirst(1:299_000, 40_000)
#--> 40000
pf()
# Executed in 0.02 second(s) in Ring 1.27
# Executed in 0.04 second(s) before
