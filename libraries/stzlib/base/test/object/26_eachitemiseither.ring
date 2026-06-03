# Narrative
# --------
# #TODO
#
# Extracted from stzObjectTest.ring, block #26.

load "../../stzBase.ring"


pr()

o1 = new stzList([ 2, 4, 8, "-129", 10, "-100.45" ])
? o1.EachItemIsEither([ :Positive, :Even, :Number ], :Or, [ :Negative, :NumberInString ] )

pf()
