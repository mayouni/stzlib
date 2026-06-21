# Narrative
# --------
# Locating every position of a value, with a case-sensitivity dial.
#
# FindAll returns the list of positions where an item matches, and is
# case-sensitive by default: searching "arem" in [ "arem", "mohsen",
# "AREM" ] finds only position 1, not the upper-case "AREM" at 3.
# FindAllCS takes an explicit :CS flag; with :CS = FALSE it folds case
# and returns both [ 1, 3 ]. FindNth narrows the same search to the Nth
# hit: case-sensitive FindNth(2, "arem") finds no second match and
# returns 0, while FindNthCS(2, "arem", :CS = FALSE) returns 3, the
# position of the second case-insensitive match.
#
# Extracted from stzlisttest.ring, block #372.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "arem", "mohsen", "AREM" ])

? @@( o1.FindAll("arem") ) + NL
#--> [ 1 ]

? o1.FindAllCS("arem", :CS = FALSE)
#--> [1, 3]

? o1.FindNth(2, "arem")
#--> 0

? o1.FindNthCS(2, "arem", :CS = FALSE)
#--> 3

pf()
# Executed in 0.02 second(s).
