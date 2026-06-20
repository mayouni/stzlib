# Narrative
# --------
# InsertAfter(:ItemAtPosition = n, item) is NON-mutating.
#
# Like the other "...ed"/query forms, calling InsertAfter computes the
# would-be list (item slipped in after position n) but does NOT change the
# object -- so o1.Content() still reads [ "A1", "A2", "A3" ] afterwards.
# Use the mutating InsertAfterPosition (or capture the return) when you
# actually want the change to stick.
#
# Extracted from stzlisttest.ring, block #364.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A1", "A2", "A3" ])
o1.InsertAfter( :ItemAtPosition = 3, "A4" )
? o1.Content()
#--> [ "A1", "A2", "A3" ]

pf()
# Executed in almost 0 second(s)
