# Narrative
# --------
# FindStzNumbers / FindStzStrings / FindStzLists / FindStzObjects: locate
# items that are wrapped SOFTANZA OBJECTS of a given kind.
#
# When a list holds Q()-elevated items (stzNumber, stzString, stzList...),
# these finders return the positions of each kind. Here Q("one") etc. are
# stzStrings (1,3,5), Q(1) etc. are stzNumbers (2,4,6), Q(1:2) is a stzList
# (7), and every Q(...) is a stz object (1-8). NullObject() at 8 is an
# object too, but neither number/string/list.
#
# Extracted from stzlisttest.ring, block #73.

load "../../stzBase.ring"

pr()

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
# Executed in almost 0 second(s) in Ring 1.27
