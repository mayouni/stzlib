# Narrative
# --------
# REVRSING ITEMS IN PAIRS AND, MORE GENERALLY, IN LISTS
#
# Extracted from stzlisttest.ring, block #71.

load "../../stzBase.ring"


# The same code you write for reversing items inside a list of pairs:

o1 = new stzListOfPairs([ [ "A1", "A2" ], [ "B1", "B2" ], ["C1", "C2" ] ])
o1.ReverseItemsInPairs()
? @@( o1.Content() )
#--> [ [ "A2", "A1" ], [ "B2", "B1" ], [ "C2", "C1" ] ]

# will work for reversing items in any list of lists:

o1 = new stzListOfLists([ [ "A1", "A2", "A3" ], [ "B1", "B2" ], ["C1", "C2" ] ])
o1.ReverseItemsInLists()
? @@( o1.Content() )
#--> [ [ "A3", "A2", "A1" ], [ "B2", "B1" ], [ "C2", "C1" ] ]

# This is a not a casual, but general feature you will find anywhere
# in Softanza: you go from specific to more general, or from general to more
# specific using nearly the same code and the same semantics.

# PS: CONSISTENCY is one of the 7 design goals of SoftanzaLib.
