# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #220.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", "C" ])

? o1.ExtractAll()
#--> [ "A", "B", "C" ]

? @@( o1.Content() )
#--> []

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.01 second(s) in Ring 1.20
