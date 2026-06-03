# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #71.

load "../../stzBase.ring"


o1 = new stzString("iloveringprogramminglanguage!!")
? @@( o1.FindManyZZ([ "i", "love", "ring", "programming" ]) )

#--> [ [ 1, 1 ], [ 2, 5 ], [ 6, 9 ], [ 7, 7 ], [ 10, 20 ], [ 18, 18 ] ]

pf()
# Executed in 0.07 second(s)
