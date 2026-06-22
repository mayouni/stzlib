# Narrative
# --------
# Removes several items in one shot by position with RemoveItemsAtThesePositions.
#
# Starting from an 8-symbol list, the call targets positions 6:8 (a Ring
# range that expands to 6, 7, 8). Those three trailing items (CObject,
# QObject, Byte) are dropped together, leaving the first five intact.
# The Q-suffixed form returns the stzList object so .Content() can be
# chained fluently to read back the survivors. This is the multi-position
# sibling of RemoveItemAtPosition: instead of one index it accepts a list
# (or range) of indices and removes them all in a single operation.
#
# Extracted from stzlisttest.ring, block #493.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :Char, :String, :Number, :List, :Object, :CObject, :QObject, :Byte ])
? o1.RemoveItemsAtThesePositionsQ( 6:8 ).Content()
#--> [ :Char, :String, :Number, :List, :Object ]

pf()
# Executed in almost 0 second(s).
