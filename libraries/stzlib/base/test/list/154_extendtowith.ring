# Narrative
# --------
# Padding a list out to a fixed length with ExtendToWith().
#
# The list starts from the char range "A":"C", which Softanza expands
# to [ "A", "B", "C" ]. ExtendToWith(5, "*") grows the list until it
# reaches length 5, appending the filler value "*" for each missing
# slot -- here two "*" entries. Existing items are left untouched; only
# the tail is padded. This is the in-place "reach this size, fill the
# gap" idiom, distinct from truncating or trimming.
#
# Extracted from stzlisttest.ring, block #154.

load "../../stzBase.ring"

pr()

o1 = new stzList("A" : "C")
o1.ExtendToWith(5, "*")
o1.Show()
#--> [ "A", "B", "C", "*", "*" ]

pf()
# Executed in 0.03 second(s)
