# Narrative
# --------
# #TODO
#
# Extracted from stzsubstringTest.ring, block #7.
#ERR Error (R3) : Calling Function without definition: only

load "../../stzBase.ring"


pr()


? Only("human").InQ([ "THE", "human", "LIFE" ]).IsInLowercase()
#--> TRUE

? Q("human").InQ([ "THE", "human", "LIFE" ]).Uppercased()
#--> [ "THE", "HUMAN", "LIFE" ]

? Only("human").InQ([ "THE", "human", "LIFE" ]).IsInLowercase() # stzOnlyItem.ring
#--> TRUE

? Every(:String).InQ([ 10, "human", 20, "human", 30, "HUMAN" ]).IsInLowercase() # stzEveryItem.ring

? Every(:Number).InQ([ 10, "human", 20, "human", 30, "HUMAN" ]).IsMultipleOf(10) # stzEveryItem.ring

pf()
