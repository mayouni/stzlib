# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #515.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

o1 = new stzString("How many <<many>> are there in (many <<<many>>>): so <many>>!")

? @@(o1.BoundsXT(:Of = "many", :UpToNChars = [ 0, 2, 0, 3, [1,2] ])) + NL
#--> [ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

//Same as:
? @@(o1.BoundsXT(:Of = "many", :UpToNChars = [ [0,0], [2, 2], [0,0], [3,3], [1,2] ]))
#--> [ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ], [ "<<<", ">>>" ], [ "<", ">>" ] ]

pf()
