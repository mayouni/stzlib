# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #20.

load "../../../stzBase.ring"


? @@( StzListQ([ "him", [ "him" ], "" ]).Sorted() ) + NL
#--> [ "", "him", [ "him" ] ]

o1 = new stzList([ "him", [ "him" ], "" ])
o1.Stringify()
? @@( o1.Content() )
o1.Sort()
#--> [ "him", '[ "him" ]', "" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
