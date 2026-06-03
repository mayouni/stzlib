# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #573.

load "../../stzBase.ring"


o1 = new stzList([ 5, [ :me, :you ], 4, "tunis", 3, 7, [ :them, :others ], "cairo"  ])
o1.SortInAscending()
? ListToCode( o1.Content() )
# Returns [ 3, 4, 5, 7, "cairo", "tunis", [ "me", "you" ], [ "them", "others" ] ]

pf()
#--> Executed in 0.02 second(s).
