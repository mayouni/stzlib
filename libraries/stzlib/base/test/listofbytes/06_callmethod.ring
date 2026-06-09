# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #6.

load "../../stzBase.ring"

pr()

// Swapping strings using stzString

o1 = new stzString("Python")
o2 = new stzString("Ring")

? CallMethod("Content()", :On = [ :o1, :o2 ])
#--> [ "Python", "Ring" ]

o1.SwapWith(o2)

? CallMethod("Content()", :On = [ :o1, :o2 ])
#--> [ "Ring", "Python" ]

// Swapping strings using stzListOfBytes

o1 = new stzListOfBytes("New")
o2 = new stzListOfBytes("Old")

? CallMethod("ToString()", :On = [ :o1, :o2 ])
#--> [ "New", "Old" ]

o1.SwapWith(o2)

? CallMethod("ToString()", :On = [ :o1, :o2 ])
#--> [ "Old", "New" ]

pf()
# Executed in 0.06 second(s)
