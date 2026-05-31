# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #637.

load "../../../stzBase.ring"


aList = [ :name = "mansour", :job = "programmer", :name = "xe" ]
o1 = new stzList(aList)

? o1.IsHashList()
#--> FALSE

pf()
# Executed in almost 0 second(s).
