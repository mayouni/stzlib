# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #481.

load "../../stzBase.ring"


o1 = new stzString('{ This[ @i - 3 ] = This[ @i + 3 ] .... @i -12233.87  @i + 764.3322 }')
? o1.NumbersAfter("@i")
#--> [ "-3", "3", "-12233.87", "764.3322" ]

? o1.NumberComingAfter("@i")
#--> "-3"

pf()
# Executed in 0.02 second(s) in Ring 1.22
