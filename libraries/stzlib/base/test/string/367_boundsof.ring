# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #367.
#ERR Error (R14) : Calling Method without definition: boundsof

load "../../stzBase.ring"

pr()

o1 = new stzString("<<<word>>>")

? o1.BoundsOf("word")
#--> [ "<<<", ">>>" ]

? o1.BoundsOfXT("word", :UpToNChars = 2)
#--> [ "<<", ">>" ]

? o1.BoundsOfXT("word", [ 1, 2 ])
#--> [ "<", ">>" ]

? o1.BoundsOfUpToNChars("word", 2)
#--> [ "<<", ">>" ]

? o1.BoundsOfUpToNChars("word", [ 1, 2 ])
#--> [ "<", ">>" ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
