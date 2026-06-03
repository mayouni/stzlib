# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #15.

load "../../stzBase.ring"


o1 = new stzHashList([
	:one	= Q(1),
	:two	= Q("2"),
	:three	= Q(3),
	:four	= Q(4),
	:five	= Q("5"),
	:six	= Q([6]),
	:seven	= Q([7])
])

? @@( o1.FindStzNumbers() )
#--> [ 1, 3, 4 ]

? @@( o1.FindStzStrings() )
#--> [ 2, 5 ]

? @@( o1.FindStzLists() )
#--> [ 6, 7 ]

? @@( o1.FindStzObjects() )
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

pf()
# Executed in 0.03 second(s)
