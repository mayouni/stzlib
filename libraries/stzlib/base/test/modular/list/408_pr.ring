# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #408.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, 3 ])
? @@( o1 + Q(4) + 5 )
#--> [ 1, 2, 3, 4, 5 ]

? @@( (o1 + Q("X" : "Z")).content() )
#--> [ 1, 2, 3, [ "X", "Y", "Z" ] ]

pf()
# Executed in 0.02 second(s).
