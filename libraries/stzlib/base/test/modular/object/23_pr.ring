# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #23.

load "../../../stzBase.ring"


o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA( :Number, :Or, :String )
#--> TRUE

pf()
# Executed in 0.14 second(s)
