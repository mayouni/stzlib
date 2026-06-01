# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #431.

load "../../../stzBase.ring"


o1 = new stzString( " This[ @i - 1 ] = This[ @i + 3 ] " )
? o1.NumbersComingAfter("@i")
#--> [ "-1", "3" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.17
