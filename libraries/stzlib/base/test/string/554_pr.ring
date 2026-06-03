# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #554.

load "../../stzBase.ring"


o1 = new stzString("12*♥*78*♥*")

? @@( o1.FindSubStringBoundedBy("♥", "*") )
#--> [ 4, 9 ]

? @@( o1.FindXT("♥", :BoundedBy = "*" ) )
#--> [ 4, 9 ]

? @@( o1.FindXT("♥", :BoundedBy = [ "*", "*" ] ) )
#--> [ 4, 9 ]

pf()
# Executed in 0.05 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20
