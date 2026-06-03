# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #548.

load "../../stzBase.ring"


o1 = new stzString("**3**67**012**56**92**")

? @@( o1.FindSubStringsBoundedBy("**") ) + NL
#--> [ 3, 6, 10, 15, 19 ]

? @@( o1.FindSubStringsBoundedByZZ("**") )
#--> [ [ 3, 3 ], [ 6, 7 ], [ 10, 12 ], [ 15, 16 ], [ 19, 20 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
