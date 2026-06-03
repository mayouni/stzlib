# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #26.

load "../../stzBase.ring"


o1 = new stzListOfLists([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() )
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
