# Narrative
# --------
# Locating the Nth occurrence of a value in a list with the @FindNth() global.
#
# @FindNth(list, n, value) returns the 1-based position of the n-th time
# the given value appears, scanning left to right. Here the list has two
# "_" entries (positions 1 and 3); asking for the 2nd occurrence yields 3.
# This is the ordinal-aware sibling of a plain find: instead of "where is
# the first match", it answers "where is the n-th match", which is handy
# for skipping past earlier duplicates without slicing the list yourself.
#
# Extracted from stzlisttest.ring, block #222.

load "../../stzBase.ring"

pr()

? @FindNth([ "_", "A", "_", "B", "C" ], 2, "_")
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.21
