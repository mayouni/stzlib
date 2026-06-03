# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #412.

load "../../stzBase.ring"


o1 = new stzList([ ".", ".", "M", ".", "I", "X" ])
? o1.FindWXT(' @char = "." ')
#--> [1, 2, 4]

pf()
# Executed in 0.08 second(s) in Ring 1.21
# Executed in 0.17 second(s) in Ring 1.17
