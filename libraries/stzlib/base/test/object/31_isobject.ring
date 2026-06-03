# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #31.

load "../../stzBase.ring"

pr()

o1 = new stzString("test")
? IsObject(o1)
#--> TRUE

? IsStzObject(o1)
#--> TRUE

# Both return TRUE --> Flexible syntax!

pf()
# Executed in 0.04 second(s)
