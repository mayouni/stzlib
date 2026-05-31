# Narrative
# --------
# #TODO
#
# Extracted from stzObjectTest.ring, block #24.

load "../../../stzBase.ring"


pr()

o1 = new stzList([ "to", -4, "be", "or", -8, "not", "to", -10, "be" ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, [ :Lowercase, :Latin, :String ])

? o1.EachItemIsEitherA([ :Negative, :Even, :Number ], :Or, :String )

? o1.EachItemIsEitherA( :Number, :Or, [ :Lowercase, :Latin, :String ])

pf()
