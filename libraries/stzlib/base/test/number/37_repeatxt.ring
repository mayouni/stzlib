# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #37.
#ERR Error (R14) : Calling Method without definition: replaceallq

load "../../stzBase.ring"

pr()

o1 = new stzNumber(5)

? @@( o1.RepeatXT(:InA = :List, :OfSize = 2) )
#--> [ 5, 5 ]

? o1.RepeatXT(:InA = :String, :OfSize = 7)
#--> "5555555"

? @@( o1.RepeatXT(:InA = :Grid, :OfSize = [3, 3]) ) + NL
#-->
# [
# 	[ 5, 5, 5 ],
# 	[ 5, 5, 5 ],
# 	[ 5, 5, 5 ]
# ]

? o1.RepeatXT(:InA = :StzTable, :OfSize = [3, 3]).Show() #NOTE that Shwo() is a misspelled
						         # form of Show(), recognised and fixed
#--> :COL1   :COL2   :COL3
#    ------ ------- ------
#       5       5       5
#       5       5       5
 #      5       5       5

pf()
# Executed in 0.30 second(s)
