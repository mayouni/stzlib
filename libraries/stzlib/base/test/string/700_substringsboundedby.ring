# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #700.

load "../../stzBase.ring"

pr()

# SubStringsBoundedBy can't manage DEEP combinations like this

o1 = new StzString( '[ "A", "T", [ :hi, [ "deep1", [] ], :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]' )
? o1.SubStringsBoundedBy([ "[", "]" ])

#!--> "A", "T", [ :hi, [ "deep1", [

pf()
# Executed in 0.01 second(s).
