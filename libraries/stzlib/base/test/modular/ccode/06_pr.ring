# Narrative
# --------
# pr()
#
# Extracted from stzccodetest.ring, block #6.

load "../../../stzBase.ring"


o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] and @i = 10 }')
? o1.NumbersAfter("@i")
#--> [ "-3", "+3" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.11 second(s) in ring 1.21
# Executed in 0.18 second(s) in Ring 1.17
