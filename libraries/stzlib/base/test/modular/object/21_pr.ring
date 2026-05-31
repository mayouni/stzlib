# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #21.

load "../../../stzBase.ring"


o1 = new stzList([ 6, -2, 9, 5, -10 ])
? o1.EachItemIsEitherA(:Positive, :Or = :Negative, :Number)
#--> TRUE

pf()
# Executed in 0.04 second(s)
