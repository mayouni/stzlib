# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #27.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

? Q([10, 20, 30 ]).IsA(:ListOfNumbers)
#--> TRUE

? Q([10, 20, 30 ]).Is(:ListOfNumbers)
#--> TRUE

? Q([ "1", "2", "3" ]).EachItemIsA([ :String, :NumberInString, :Char ])
#--> TRUE


pf()
# Executed in 0.03 second(s)
