# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #479.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", "_", "C", "D", "E", "F" ])
? @@( o1.AllItemsExcept("_") )
#--> [ "A", "B", "C", "D", "E", "F" ]

StopProfiler()
# Executed in almost 0 second(s).
