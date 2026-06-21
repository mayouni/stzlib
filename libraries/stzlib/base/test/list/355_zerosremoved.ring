# Narrative
# --------
# Demonstrates ZerosRemoved(): drop every 0 entry from a list, keeping
# all non-zero items in their original order.
#
# Softanza treats 0 as a removable "blank" sentinel in mixed lists.
# ZerosRemoved() returns a fresh list with all 0 elements filtered out,
# leaving the surviving items untouched and in sequence. It is the
# value-specific cousin of the general remove-by-value family, handy for
# cleaning up sparse or padded numeric/mixed arrays.
#
# Extracted from stzlisttest.ring, block #355.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 0, 0, "B", "C", 0, "D", 0, 0 ])
? o1.ZerosRemoved()
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in almost 0 second(s).
