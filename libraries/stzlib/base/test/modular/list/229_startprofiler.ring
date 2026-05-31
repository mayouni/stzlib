# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #229.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, "♥", 4, "♥", 6, "♥" ])

? o1.ExtractNext("♥", :StartingAt = 4)
#--> "♥"

? @@( o1.Content() )
#--> [ 1, 2, "♥", 4, 6, "♥" ]

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
