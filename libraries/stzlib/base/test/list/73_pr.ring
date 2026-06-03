# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #73.

load "../../stzBase.ring"


o1 = new stzList([ Q("one"), Q(1), Q("two"), Q(2), Q("three"), Q(3), Q(1:2), NullObject() ])

? @@( o1.FindStzNumbers() )
#--> [ 2, 4, 6 ]

? @@( o1.FindStzStrings() )
#--> [ 1, 3, 5 ]

? @@( o1.FindStzLists() )
#--> [ 7 ]

? @@( o1.FindStzObjects() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]

pf()
