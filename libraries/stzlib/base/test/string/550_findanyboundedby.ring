# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #550.

load "../../stzBase.ring"

pr()

o1 = new stzString("txt <<ring>> txt <<php>>")

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [7, 20]

pf()
# Executed in 0.01 second(s) in Ring 1.22
