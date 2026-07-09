# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #298.

load "../../stzBase.ring"

pr()

o1 = new stzList(["__", "♥", "_", "__", "♥", "♥", "__", "♥" ])
? o1.FindAll("♥")
#--> [2, 5, 6, 8 ]

o1 = new stzList(["__", 1:3, "_", "__", 1:3, 1:3, "__", 1:3 ])
? o1.FindAll(1:3)
#--> [2, 5, 6, 8 ]

StopProfiler()

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.60 second(s) in Ring 1.17
