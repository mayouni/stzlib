# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #218.

load "../../../stzBase.ring"


 # Extract(item) removes the item from the list and returns it

o1 = new stzList([ "A", "B", "_", "C" ])

? o1.Extract("_")
#--> "_"

? o1.Content()
#--> [ "A", "B", "C" ]

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
