# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #1.

load "../../../stzBase.ring"


o1 = new stzString('[ @$2{"a";1;[1]}U ]')
? @@( o1.FindTheseBounds("[", "]") )
#--> [ 1, 15 ]

o1.RemoveTheseBounds("[", "]")
? @@(o1.Content())
#--> ' @$2{"a";1;[1}U ]'

pf()
# Executed in 0.03 second(s) in Ring 1.26
# Executed in 0.05 second(s) in Ring 1.22
