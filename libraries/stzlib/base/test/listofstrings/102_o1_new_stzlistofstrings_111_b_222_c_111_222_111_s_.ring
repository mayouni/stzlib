# Narrative
# --------
# o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
#
# Extracted from stzlistofstringstest.ring, block #102.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "111", "b", "222", "c", "111", "222", "111", "s", "222" ])
#
? @@( o1.DuplicatedStrings() ) #--> [ "111", "222" ]

o1.RemoveDuplicates()
? @@( o1.Content() ) #--> [ "111", "b", "222", "c", "s" ]

pf()
