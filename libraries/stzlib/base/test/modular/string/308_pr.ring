# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #308.

load "../../../stzBase.ring"


o1 = new stzString("99999999999")

o1.InsertXT("_", :EachNChars = 3)
//o1.InsertXT("_", [ :EachNChars = 3, :Forward ]) #TODO

? o1.Content()
#--> 999_999_999_99

pf()
# Executed in 0.05 second(s)
