# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #430.
#ERR Error (R14) : Calling Method without definition: nthnumbercomingafter

load "../../stzBase.ring"

pr()

o1 = new stzString( " This 10 : @i - 1.23 and this: @i + 378.12! " )
? o1.NumbersComingAfter("@i")
#--> [ "-1.23", "378.12" ]

? o1.NthNumberComingAfter(2, "@i") + NL
#--> "378.12"

? o1.Numbers()
#--> [ "10", "-1.23", "378.12" ]

StopProfiler()

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.51 second(s) in Ring 1.17
