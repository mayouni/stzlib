# Narrative
# --------
# pr()
#
# Extracted from stzGridTest.ring, block #7.

load "../../stzBase.ring"


o1 = new stzGrid([3, 2])

o1.MoveTo(3, 1)
? @@( o1.Position() )
#--> [ 3, 1 ]

o1.MoveRight() # Won't move and stays on last node
? @@( o1.Position() )
#--> [ 3, 1 ]

o1.MoveUp() # Idem
? @@( o1.Position() )
#--> [ 3, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
