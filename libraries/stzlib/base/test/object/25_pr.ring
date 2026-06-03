# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #25.

load "../../stzBase.ring"


o1 = new stzList([ 120, "1250", 54, "452" ])
? o1.EachItemIsEither( :Number, :Or, :NumberInString )
#--> TRUE

pf()
# Executed in 0.04 second(s)
