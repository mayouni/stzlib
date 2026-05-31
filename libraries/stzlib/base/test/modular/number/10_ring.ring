# Narrative
# --------
# @ring
#
# Extracted from stznumbertest.ring, block #10.

load "../../../stzBase.ring"


pr()

aHash = [ :1 = "One", :2 = "Two", :3 = "Three" ]

? @@(aHash)
#--> [ [ "1", "One" ], [ "2", "Two" ], [ "3", "Three" ] ]

? isString(aHash[1][1]) # "1"
#--> TRUE

? @@( aHash[1] )
#--> [ "1", "One" ]

? aHash[:1]
#--> "One"

pf()
# Executed in almost 0 second(s) in Ring 1.21
