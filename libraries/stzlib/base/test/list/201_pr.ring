# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #201.

load "../../stzBase.ring"


o1 = new stzList([ 12, 88 ])
? o1.BothAreNumbers()
#--> TRUE

o1 = new stzList([ "hi", "ring" ])
? o1.BothAreStrings()
#--> TRUE

o1 = new stzList([ :name = "Dan", :job = "Programmer" ])
? o1.BothAreLists()
#--> TRUE

o1 = new stzList([ o1, o1 ])
? o1.BothAreObjects()
#--> TRUE

pf()
# Executed in 0.05 second(s)
