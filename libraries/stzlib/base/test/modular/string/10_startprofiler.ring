# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #10.

load "../../../stzBase.ring"


? @@( AlignCenter("RING", 15) )
#--> "     RING      "

? @@( AlignLeft("RING", 15) )
#--> "RING           "

? @@( AlignRight("RING", 15) ) + NL
#-->"           RING"


? @@( AlignCenterXT("RING", 15, ".") )
#--> ".....RING......"

? @@( AlignLeftXT("RING", 15, ".") )
#--> "RING..........."

? @@( AlignRightXT("RING", 15, ".") ) + NL
#--> "...........RING"


? @@( AlignXT("RING", 15, "~", :Center) )
#--> "~~~~~RING~~~~~~"

? @@( AlignXT("RING", 15, "~", :Right) )
#--> "~~~~~RING~~~~~~"

? @@( AlignXT("RING", 15, "~", :Left) )
#--> "~~~~~RING~~~~~~"

StopProfiler()
# Executed in 0.03 second(s).
