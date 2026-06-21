# Narrative
# --------
# ExtendTo() grows a list in place until it reaches a target length.
#
# Building a list from the char range "A":"C" yields [ "A", "B", "C" ].
# Calling ExtendTo(5) lengthens it to five items, appending empty
# strings ("") for the two missing slots rather than nil or zero. This
# is the Softanza convention for length-padding: the original items are
# preserved untouched and the new tail positions are filled with the
# neutral empty value, so a freshly extended list is immediately safe
# to index across its whole new range.
#
# Extracted from stzlisttest.ring, block #152.

load "../../stzBase.ring"

pr()

o1 = new stzList("A" : "C")
o1.ExtendTo(5)
o1.Show()
#--> [ "A", "B", "C", "", "" ]

pf()
# Executed in 0.03 second(s)
