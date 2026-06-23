# Narrative
# --------
# The (+) operator: adding to a stzList, and what Q() adds.
#
# `o1 + Q(4) + 5` chains adds: Q(4) (a stzNumber) contributes its numeric
# value 4, then the raw 5 -- giving [1,2,3,4,5]. When the right operand is
# a Q()-wrapped LIST, its Content() is added as ONE item (a sublist), and
# because the operand was Q()-elevated the result is a chainable stzList
# object -- hence the .content() call returns [1,2,3,[ "X","Y","Z" ]].
#
# Extracted from stzlisttest.ring, block #408.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3 ])
? @@( o1 + Q(4) + 5 )
#--> [ 1, 2, 3, 4, 5 ]

? @@( (o1 + Q("X" : "Z")).content() )
#--> [ 1, 2, 3, [ "X", "Y", "Z" ] ]

pf()
# Executed in 0.02 second(s)
