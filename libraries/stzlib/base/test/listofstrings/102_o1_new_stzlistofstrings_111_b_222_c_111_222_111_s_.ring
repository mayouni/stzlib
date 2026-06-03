# Narrative
# --------
# o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
#
# Extracted from stzlistofstringstest.ring, block #102.

load "../../stzBase.ring"

pr()

? @@( o1.DuplicatedStrings() ) #--> [ "111", "222" ]

o1.RemoveDuplicates()
? @@( o1.Content() ) #--> [ "111", "b", "222", "c", "s" ]

pf()
